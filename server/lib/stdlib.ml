open Core
open Runtime
open Lib

let fns : Lib.shortfn list = [
  (* { n = "Page::page" *)
  (* ; o = [] *)
  (* ; p = ["url"; "outputs"] *)
  (* ; f = function *)
  (*     | args -> expected "this to be implmented" args *)
  (* } *)
  (* ; *)


  (* ====================================== *)
  (* Dict  *)
  (* ====================================== *)

  { n = "Dict::keys"
  ; o = []
  ; p = [req "dict" TObj]
  ; r = TList
  ; d = ""
  ; f = InProcess
        (function
          | [DObj o] -> o
                        |> DvalMap.keys
                        |> List.map ~f:(fun k -> DStr k)
                        |> fun l -> DList l
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "."
  ; o = ["get_field"]
  ; p = [req "value" TObj; req "fieldname" TStr]
  ; r = TAny
  ; d = ""
  ; f = InProcess
        (function
          | [DObj value; DStr fieldname] ->
            (match DvalMap.find value fieldname with
             | None -> Exception.raise ("Value has no field named: " ^ fieldname)
             | Some v -> v)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  (* ====================================== *)
  (* Int *)
  (* ====================================== *)
  { n = "%"
  ; o = ["Int::mod"]
  ; p = [req "a" TInt ; req "b" TInt]
  ; r = TInt
  ; d = ""
  ; f = InProcess
        (function
          | [DInt a; DInt b] -> DInt (a mod b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "+"
  ; o = ["Int::add"]
  ; p = [req "a" TInt ; req "b" TInt]
  ; r = TInt
  ; d = "Adds two integers together"
  ; f = InProcess
        (function
          | [DInt a; DInt b] -> DInt (a + b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "-"
  ; o = ["Int::subtract"]
  ; p = [req "a" TInt ; req "b" TInt]
  ; r = TInt
  ; d = "Subtracts two integers"
  ; f = InProcess
        (function
          | [DInt a; DInt b] -> DInt (a - b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "*"
  ; o = ["Int::multiply"]
  ; p = [req "a" TInt ; req "b" TInt]
  ; r = TInt
  ; d = "Multiples two integers"
  ; f = InProcess
        (function
          | [DInt a; DInt b] -> DInt (a * b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "/"
  ; o = ["Int::divide"]
  ; p = [req "a" TInt ; req "b" TInt]
  ; r = TInt
  ; d = "Divides two integers"
  ; f = InProcess
        (function
          | [DInt a; DInt b] -> DInt (a / b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = ">"
  ; o = ["Int::greaterThan"]
  ; p = [req "a" TInt ; req "b" TInt]
  ; r = TBool
  ; d = "Returns true if a is greater than b"
  ; f = InProcess
        (function
          | [DInt a; DInt b] -> DBool (a > b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "<"
  ; o = ["Int::lessThan"]
  ; p = [req "a" TInt ; req "b" TInt]
  ; r = TBool
  ; d = "Returns true if a is less than b"
  ; f = InProcess
        (function
          | [DInt a; DInt b] -> DBool (a < b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;

  { n = "<="
  ; o = ["Int::lessThanOrEqualTo"]
  ; p = [req "a" TInt ; req "b" TInt]
  ; r = TBool
  ; d = "Returns true if a is less than or equal to b"
  ; f = InProcess
        (function
          | [DInt a; DInt b] -> DBool (a <= b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = ">="
  ; o = ["Int::greaterThanOrEqualTo"]
  ; p = [req "a" TInt ; req "b" TInt]
  ; r = TBool
  ; d = "Returns true if a is greater than or equal to b"
  ; f = InProcess
        (function
          | [DInt a; DInt b] -> DBool (a >= b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  (* ====================================== *)
  (* Any *)
  (* ====================================== *)
  { n = "toString"
  ; o = []
  ; p = [req "v" TAny]
  ; r = TStr
  ; d = "Returns a string representation of `v`"
  ; f = InProcess
        (function
          | [a] -> DStr (to_repr a)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "=="
  ; o = ["equals"]
  ; p = [req "a" TAny; req "b" TAny]
  ; r = TBool
  ; d = "Returns true if the two value are equal"
  ; f = InProcess
        (function
          | [a; b] -> DBool (equal_dval a b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  (* ====================================== *)
  (* Bool *)
  (* ====================================== *)
  { n = "Bool::not"
  ; o = []
  ; p = [req "b" TBool]
  ; r = TBool
  ; d = ""
  ; f = InProcess
        (function
          | [DBool b] -> DBool (not b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "&&"
  ; o = ["Bool::and"]
  ; p = [req "a" TBool ; req "b" TBool]
  ; r = TBool
  ; d = "Returns true if both a and b are true"
  ; f = InProcess
        (function
          | [DBool a; DBool b] -> DBool (a && b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "||"
  ; o = ["Bool::or"]
  ; p = [req "a" TBool ; req "b" TBool]
  ; r = TBool
  ; d = "Returns true if either a is true or b is true"
  ; f = InProcess
        (function
          | [DBool a; DBool b] -> DBool (a || b)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  (* ====================================== *)
  (* String *)
  (* ====================================== *)
  { n = "String::foreach"
  ; o = []
  ; p = [req "s" TStr; func ["item"]]
  ; r = TStr
  ; d = "Run `f` on every character in the string, and combine them back into a string"
  ; f = InProcess
        (function
          | [DStr s; DAnon (id, fn)] ->
            let charf (c: char) : char =
              let result = fn [(DChar c)] in
              match result with
              | DChar c -> c
              | r -> Exception.raise "expected a char"
            in
            DStr (String.map ~f:charf s)
          | args -> fail args)
  ; pr = Some
        (function
          | [DStr s; _] ->
              if s = ""
              then [DChar 'l']
              else [DChar (String.get s 0)]
          | args -> [DIncomplete])
  ; pu = true
  }
  ;

  { n = "String::toList"
  ; o = []
  ; p = [req "s" TStr]
  ; r = TList
  ; d = "Returns the list of characters in the string"
  ; f = InProcess
        (function
          | [DStr s] ->
              DList (String.to_list s |> List.map ~f:(fun c -> DChar c))
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "String::fromList"
  ; o = []
  ; p = [req "l" TList]
  ; r = TStr
  ; d = "Returns the list of characters as a string"
  ; f = InProcess
        (function
          | [DList l] ->
              DStr (l |> List.map ~f:(function
                                      | DChar c -> c
                                      | _ -> Exception.raise "expected a char")
                      |> String.of_char_list)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  (* ====================================== *)
  (* List *)
  (* ====================================== *)
  { n = "List::head"
  ; o = []
  ; p = [req "list" TList]
  ; r = TAny
  ; d = ""
  ; f = InProcess
        (function
          | [DList l] -> List.hd_exn l
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "List::empty"
  ; o = []
  ; p = []
  ; r = TList
  ; d = ""
  ; f = InProcess
        (function
          | [] -> DList []
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;

  { n = "List::new"
  ; o = []
  ; p = [opt "i1" TAny; opt "i2" TAny; opt "i3" TAny; opt "i4" TAny; opt "i5" TAny; opt "i6" TAny]
  ; r = TList
  ; d = "Return a new list with the arguments provided"
  ; f = InProcess
        (function
          | args -> DList (List.filter ~f:(fun x -> x <> DIncomplete && x <> DNull) args))
  ; pr = None
  ; pu = true
  }
  ;


  { n = "List::push"
  ; o = ["List::cons"]
  ; p = [req "item" TAny; req "list" TList]
  ; r = TList
  ; d = ""
  ; f = InProcess
        (function
          | [i; DList l] -> DList (i :: l)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "List::last"
  ; o = []
  ; p = [req "list" TList]
  ; r = TAny
  ; d = ""
  ; f = InProcess
        (function
          | [DList l] -> List.last_exn l
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;

  { n = "List::find_first"
  ; o = []
  ; p = [req "l" TList; func ["item"]]
  ; r = TList
  ; d = "Find the first element of the list, for which `f` returns true"
  ; f = InProcess
        (function
          | [DList l; DAnon (id, fn)] ->
            (let f (dv: dval) : bool = DBool true = fn [dv]
            in
            match List.find ~f l with
            | None -> DNull
            | Some dv -> dv)
        | args -> fail args)
  ; pr = Some
        (function
          | [DList (i :: _); _] -> [i]
          | args -> [DIncomplete])
  ; pu = true
  }
  ;


  { n = "List::contains"
  ; o = []
  ; p = [req "l" TList; req "item" TAny]
  ; r = TBool
  ; d = "Returns if the item is in the list"
  ; f = InProcess
        (function
          | [DList l; i] -> DBool (List.mem ~equal:equal_dval l i)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "List::repeat"
  ; o = []
  ; p = [req "times" TInt; req "item" TAny]
  ; r = TList
  ; d = "Returns a list containing `item` repeated `count` times"
  ; f = InProcess
        (function
          | [DInt t; item] -> DList (List.init t ~f:(fun _ -> item))
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "List::length"
  ; o = []
  ; p = [req "l" TList]
  ; r = TInt
  ; d = "Returns the length of the list"
  ; f = InProcess
        (function
          | [DList l] -> DInt (List.length l)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "List::fold"
  ; o = []
  ; p = [req "l" TList; req "init" TAny; func ["new"; "old"]]
  ; r = TAny
  ; d = "Folds the list into a single value, by repeatedly apply `f` to any two pairs"
  ; f = InProcess
        (function
          | [DList l; init; DAnon (id, fn)] ->
            let f (dv1: dval) (dv2: dval) : dval = fn [dv1; dv2]
            in
            List.fold ~f ~init l
          | args -> fail args)
  ; pr = Some
        (function
          | [DList l; init; _] ->
              let prl = match List.hd l with
              | Some dv -> dv
              | None -> DIncomplete
              in [prl; init]
          | args -> [DIncomplete; DIncomplete])
  ; pu = true
  }
  ;


  { n = "List::flatten"
  ; o = []
  ; p = [req "l" TList]
  ; r = TList
  ; d = "Returns a single list containing the elements of all the lists in `l`"
  ; f = InProcess
        (function
          | [DList l] ->
              let f = fun a b ->
                match (a, b) with
                  | (DList a, DList b) -> DList (List.append a b)
                  | _ -> DIncomplete
              in
              List.fold ~init:(DList []) ~f l
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "List::append"
  ; o = []
  ; p = [req "l1" TList; req "l2" TList]
  ; r = TList
  ; d = "Returns the combined list of `l1` and `l2`"
  ; f = InProcess
        (function
          | [DList l1; DList l2] -> DList (List.append l1 l2)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;



  { n = "List::filter"
  ; o = []
  ; p = [req "l" TList; func ["item"]]
  ; r = TList
  ; d = "Return only items in list which meet function criteria"
  ; f = InProcess
        (function
          | [DList l; DAnon (id, fn)] ->
            let f (dv: dval) : bool =
            match fn [dv] with
            | DBool b -> b
            | dv -> fail [dv]
            in
            DList (List.filter ~f l)
          | args -> fail args)
  ; pr = Some
        (function
          | [DList l; _] ->
              (match List.hd l with
              | Some dv -> [dv]
              | None -> [DIncomplete])
          | args -> [DIncomplete])
  ; pu = true
  }
  ;


  { n = "List::foreach"
  ; o = []
  ; p = [req "l" TList; func ["item"]]
  ; r = TList
  ; d = "Call `f` on every item in the list, returning a list of the results of
  those calls"
  ; f = InProcess
        (function
          | [DList l; DAnon (id, fn)] ->
            let f (dv: dval) : dval = fn [dv]
            in
            DList (List.map ~f l)
          | args -> fail args)
  ; pr = Some
        (function
          | [DList l; _] ->
              (match List.hd l with
              | Some dv -> [dv]
              | None -> [DIncomplete])
          | args -> [DIncomplete])
  ; pu = true
  }
  ;


  (* ====================================== *)
  (* Date *)
  (* ====================================== *)
  { n = "Date::parse"
  ; o = []
  ; p = [req "s" TStr]
  ; r = TInt
  ; d = "Parses a time string, and return the number of seconds since the epoch (midnight, Jan 1, 1970)"
  ; f = InProcess
        (function
          | [DStr s] ->
              DInt (s
                    |> Unix.strptime ~fmt:"%a %b %d %H:%M:%S %z %Y"
                    |> Unix.timegm
                    |> int_of_float
                    )
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "Date::now"
  ; o = []
  ; p = []
  ; r = TInt
  ; d = "Returns the number of seconds since the epoch (midnight, Jan 1, 1970)"
  ; f = InProcess
        (function
          | [] ->
              DInt (Unix.time ()
                    |> int_of_float
                    )
          | args -> fail args)
  ; pr = None
  ; pu = false
  }
  ;


  (* ====================================== *)
  (* Char *)
  (* ====================================== *)
  { n = "Char::toASCIICode"
  ; o = []
  ; p = [req "c" TChar]
  ; r = TInt
  ; d = "Return `c`'s ASCII code"
  ; f = InProcess
        (function
          | [DChar c] -> DInt (Char.to_int c)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "Char::toASCIIChar"
  ; o = []
  ; p = [req "i" TInt]
  ; r = TChar
  ; d = ""
  ; f = InProcess
        (function
          | [DInt i] -> DChar (Char.of_int_exn i)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "Char::toLowercase"
  ; o = []
  ; p = [req "c" TChar]
  ; r = TChar
  ; d = "Return the lowercase value of `c`"
  ; f = InProcess
        (function
          | [DChar c] -> DChar (Char.lowercase c)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;


  { n = "Char::toUppercase"
  ; o = []
  ; p = [req "c" TChar]
  ; r = TChar
  ; d = "Return the uppercase value of `c`"
  ; f = InProcess
        (function
          | [DChar c] -> DChar (Char.uppercase c)
          | args -> fail args)
  ; pr = None
  ; pu = true
  }
  ;



]
