(* NOTE: This will change in the future to pretty tool tips, this is just an inbetween state *)
open Prelude

type toolTipDirection =
  | Left
  | Right
  | Top
  | Bottom

and tooltipStyle =
  | Tutorial of tutorialStep
  | Crud
  | Default

and tooltipContent =
  { title : string
  ; details : string list option
  ; action : (string * msg) option
  ; align : toolTipDirection
  ; tipAlignment : string
  ; tooltipStyle : tooltipStyle }

(** [currentStepFraction currentStep] returns a tuple of the form [(currentStepNumber, totalSteps)], given the [currentStep]. *)
let currentStepFraction (currentStep : tutorialStep) : int * int =
  let currentStepNumber =
    match currentStep with
    | Welcome ->
        1
    | VerbChange ->
        2
    | ReturnValue ->
        3
    | OpenTab ->
        4
    | GettingStarted ->
        5
  in
  let totalSteps = 5 in
  (currentStepNumber, totalSteps)


let stepNumToStep (currentStep : int) : tutorialStep option =
  match currentStep with
  | 1 ->
      Some Welcome
  | 2 ->
      Some VerbChange
  | 3 ->
      Some ReturnValue
  | 4 ->
      Some OpenTab
  | 5 ->
      Some GettingStarted
  | _ ->
      None


let getPrevStep (current : tutorialStep option) : tutorialStep option =
  match current with
  | Some step ->
      let currentStepNumber, _ = currentStepFraction step in
      stepNumToStep (currentStepNumber - 1)
  | None ->
      None


let getNextStep (current : tutorialStep option) : tutorialStep option =
  match current with
  | Some step ->
      let currentStepNumber, _ = currentStepFraction step in
      stepNumToStep (currentStepNumber + 1)
  | None ->
      None


let assignTutorialToHTTPHandler
    (tooltipState : tooltipState) (tl : toplevel) (tlid : TLID.t) : tooltipState
    =
  if tooltipState.userTutorial.step = Some Welcome
     && tooltipState.userTutorial.tlid = None
     && Toplevel.isHTTPHandler tl
  then
    { tooltipState with
      userTutorial = {tooltipState.userTutorial with tlid = Some tlid} }
  else tooltipState


let update (tooltipState : tooltipState) (msg : toolTipMsg) : modification =
  let tooltipState, mods =
    let currentTooltip = tooltipState.tooltipSource in
    match msg with
    | OpenTooltip tt
      when (not (Option.isSome currentTooltip)) || Some tt <> currentTooltip ->
        ({tooltipState with tooltipSource = Some tt}, [])
    | OpenTooltip _ | Close ->
        ({tooltipState with tooltipSource = None}, [])
    | OpenLink url ->
        Native.Window.openUrl url "_blank" ;
        ({tooltipState with tooltipSource = None}, [])
    | OpenFnTooltip fnSpace ->
        ({tooltipState with fnSpace}, [])
    | UpdateTutorial tutorialMsg ->
        let userTutorial, mods =
          match tutorialMsg with
          | NextStep ->
              if tooltipState.userTutorial.step = Some Welcome
                 && tooltipState.userTutorial.tlid = None
              then
                ( tooltipState.userTutorial
                , [ ReplaceAllModificationsWithThisOne
                      (fun m ->
                        ( { m with
                            toast =
                              { m.toast with
                                toastMessage =
                                  Some
                                    "Create a new HTTP Handler to continue tutorial"
                              } }
                        , Tea.Cmd.none )) ] )
              else
                let step = getNextStep tooltipState.userTutorial.step in
                ({tooltipState.userTutorial with step}, [])
          | PrevStep ->
              let step = getPrevStep tooltipState.userTutorial.step in
              ({tooltipState.userTutorial with step}, [])
          | CloseTutorial ->
              ( {step = None; tlid = None}
              , [ ReplaceAllModificationsWithThisOne
                    (fun m ->
                      ( { m with
                          firstVisitToDark = false
                        ; firstVisitToThisCanvas = false }
                      , Tea.Cmd.none )) ] )
          | ReopenTutorial ->
              ({step = Some Welcome; tlid = None}, [])
        in
        ({tooltipState with userTutorial}, mods)
  in
  if List.isEmpty mods
  then
    ReplaceAllModificationsWithThisOne
      (fun m -> ({m with tooltipState}, Tea.Cmd.none))
  else
    Many
      ( mods
      @ [ ReplaceAllModificationsWithThisOne
            (fun m -> ({m with tooltipState}, Tea.Cmd.none)) ] )


let generateContent (t : tooltipSource) : tooltipContent =
  match t with
  | Http ->
      { title = "Click the plus sign to create a REST API endpoint."
      ; details = None
      ; action =
          Some
            ( "Learn More"
            , ToolTipMsg
                (OpenLink "https://darklang.github.io/docs/first-api-endpoint")
            )
      ; align = Bottom
      ; tipAlignment = "align-left"
      ; tooltipStyle = Default }
  | Worker ->
      { title =
          "Click the plus sign to create a worker to process asynchronous tasks."
      ; details = None
      ; action =
          Some
            ( "Learn More"
            , ToolTipMsg
                (OpenLink "https://darklang.github.io/docs/first-worker") )
      ; align = Bottom
      ; tipAlignment = "align-left"
      ; tooltipStyle = Default }
  | Cron ->
      { title = "Click the plus sign to create a scheduled job."
      ; details = None
      ; action =
          Some
            ( "Learn More"
            , ToolTipMsg (OpenLink "https://darklang.github.io/docs/first-cron")
            )
      ; align = Bottom
      ; tipAlignment = "align-left"
      ; tooltipStyle = Default }
  | Repl ->
      { title = "Click the plus sign to create a general purpose coding block."
      ; details = None
      ; action =
          Some
            ( "Learn More"
            , ToolTipMsg (OpenLink "https://darklang.github.io/docs/first-repl")
            )
      ; align = Bottom
      ; tipAlignment = "align-left"
      ; tooltipStyle = Default }
  | Datastore ->
      { title = "Click to create a key-value store."
      ; details = None
      ; action =
          Some
            ( "Learn More"
            , ToolTipMsg
                (OpenLink "https://darklang.github.io/docs/first-datastore") )
      ; align = Bottom
      ; tipAlignment = "align-left"
      ; tooltipStyle = Default }
  | Function ->
      { title = "Click to create a reusable block of code."
      ; details = None
      ; action =
          Some
            ( "Learn More"
            , ToolTipMsg
                (OpenLink "https://darklang.github.io/docs/first-function") )
      ; align = Bottom
      ; tipAlignment = "align-left"
      ; tooltipStyle = Default }
  | FourOhFour ->
      { title =
          "Attempts to hit endpoints that do not yet have handlers appear here."
      ; details =
          Some
            [ "If you're looking for a 404 but not seeing it in this list, check the 'Deleted' section of the sidebar."
            ]
      ; action =
          Some
            ( "Learn More"
            , ToolTipMsg
                (OpenLink
                   "https://darklang.github.io/docs/trace-driven-development")
            )
      ; align = Bottom
      ; tipAlignment = "align-left"
      ; tooltipStyle = Default }
  | Deleted ->
      { title = "Deleted handlers appear here."
      ; details = None
      ; action = None
      ; align = Bottom
      ; tipAlignment = "align-left"
      ; tooltipStyle = Default }
  | PackageManager ->
      { title =
          "A list of built-in Dark functions. Click on the name of the function to preview it."
      ; details =
          Some
            [ "To use the function in your canvas, start typing its name in your handler and select it from autocomplete."
            ]
      ; action = None
      ; align = Bottom
      ; tipAlignment = "align-left"
      ; tooltipStyle = Default }
  | StaticAssets ->
      { title = "Learn more about hosting static assets here."
      ; details = None
      ; action =
          Some
            ( "Learn More"
            , ToolTipMsg
                (OpenLink "https://darklang.github.io/docs/static-assets") )
      ; align = Bottom
      ; tipAlignment = "align-left"
      ; tooltipStyle = Default }
  | FnParam ->
      { title =
          "If a function has parameters, it will need to be called once from another handler in order to assign values to the parameters and display live values. Until this happens, the function will display a warning."
      ; details = None
      ; action = None
      ; align = Left
      ; tipAlignment = ""
      ; tooltipStyle = Default }
  | FnMiniMap ->
      { title =
          "Functions live in the function space, which is separate from your main canvas. You can return to your main canvas by clicking on the name of another handler in the sidebar or the minimap in the lower right."
      ; details = None
      ; action = None
      ; align = Top
      ; tipAlignment = ""
      ; tooltipStyle = Default }
  | Secrets ->
      { title = "Store API keys, passwords or other secrets here."
      ; details =
          Some
            [ "Secret names will appear in your autocomplete, but their values will be redacted from live values and traces."
            ]
      ; action = None
      ; align = Bottom
      ; tipAlignment = "align-left"
      ; tooltipStyle = Default }


let viewNavigationBtns
    (tlid : TLID.t option) (step : tutorialStep) (uniqueStr : string) :
    msg Html.html =
  let prevBtn =
    let clickEvent =
      match getPrevStep (Some step) with
      | Some _ ->
          let stepNum, _ = currentStepFraction step in
          ViewUtils.eventNoPropagation
            ~key:("prev-step-" ^ string_of_int stepNum ^ "-" ^ uniqueStr)
            "click"
            (fun _ -> ToolTipMsg (UpdateTutorial PrevStep))
      | None ->
          Vdom.noProp
    in
    Html.button
      [ Html.class' "page-btn"
      ; ViewUtils.nothingMouseEvent "mousedown"
      ; ViewUtils.nothingMouseEvent "mouseup"
      ; clickEvent
      ; Html.Attributes.disabled (clickEvent = Vdom.noProp) ]
      [Html.text "Previous"]
  in
  let nextBtn =
    let clickEvent =
      match getNextStep (Some step) with
      | Some _ when Option.isSome tlid ->
          let stepNum, _ = currentStepFraction step in
          ViewUtils.eventNoPropagation
            ~key:("next-step-" ^ string_of_int stepNum ^ "-" ^ uniqueStr)
            "click"
            (fun _ -> ToolTipMsg (UpdateTutorial NextStep))
      | Some _ | None ->
          Vdom.noProp
    in
    Html.button
      [ Html.class' "page-btn"
      ; ViewUtils.nothingMouseEvent "mousedown"
      ; ViewUtils.nothingMouseEvent "mouseup"
      ; clickEvent
      ; Html.Attributes.disabled (clickEvent = Vdom.noProp) ]
      [Html.text "Next"]
  in
  Html.div [Html.class' "btn-container"] [prevBtn; nextBtn]


let viewToolTip
    ~(shouldShow : bool) ~(tlid : TLID.t option) (t : tooltipContent) :
    msg Html.html =
  if shouldShow
  then
    let uniqueStr =
      match tlid with Some id -> TLID.toString id | None -> t.title
    in
    let viewDesc = Html.h1 [Html.class' "description"] [Html.text t.title] in
    let viewDetail =
      match t.details with
      | Some txtList ->
          let txtview =
            List.map
              ~f:(fun txt -> Html.p [Html.class' "details"] [Html.text txt])
              txtList
          in
          Html.div [] txtview
          (* Html.p [Html.class' "details"] [Html.text txt] *)
      | None ->
          Vdom.noNode
    in
    let viewBtn =
      match t.action with
      | Some (text, action) ->
          Html.button
            [ Html.class' "action-button"
            ; ViewUtils.eventNoPropagation
                ~key:("close-settings" ^ text)
                "click"
                (fun _ -> action) ]
            [Html.p [] [Html.text text]]
      | None ->
          Vdom.noNode
    in
    let closeBtn =
      match t.tooltipStyle with
      | Tutorial _ | Crud ->
          Html.button
            [ Html.class' "page-btn"
            ; ViewUtils.nothingMouseEvent "mousedown"
            ; ViewUtils.nothingMouseEvent "mouseup"
            ; ViewUtils.eventNoPropagation
                ~key:("close-tutorial-" ^ uniqueStr)
                "click"
                (fun _ -> ToolTipMsg (UpdateTutorial CloseTutorial)) ]
            [Html.text "End tutorial"]
      | Default ->
          Vdom.noNode
    in
    let viewStepCount =
      match t.tooltipStyle with
      | Tutorial step ->
          let current, total = currentStepFraction step in
          Html.p
            [Html.class' "step-title"]
            [Html.text (Printf.sprintf "%d/%d" current total)]
      | Crud | Default ->
          Vdom.noNode
    in
    let viewNextPrevBtns =
      match t.tooltipStyle with
      | Tutorial step ->
          viewNavigationBtns tlid step uniqueStr
      | Crud | Default ->
          Vdom.noNode
    in
    let directionToClass =
      match t.align with
      | Top ->
          "above"
      | Bottom ->
          "below"
      | Left ->
          "left-of"
      | Right ->
          "right-of"
    in
    Html.div
      [Html.class' "tooltipWrapper"]
      [ Html.div
          ~unique:uniqueStr
          [Html.class' ("tooltips " ^ directionToClass)]
          [ Html.div
              [Html.class' "content"]
              [ viewStepCount
              ; viewDesc
              ; viewDetail
              ; viewBtn
              ; viewNextPrevBtns
              ; closeBtn ]
          ; Html.div [Html.class' ("tip " ^ t.tipAlignment)] [] ] ]
  else Vdom.noNode
