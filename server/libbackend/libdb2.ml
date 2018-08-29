open Core_kernel
open Libexecution

open Lib
open Runtime
open Types.RuntimeT


let fns : Lib.shortfn list = [
  { pns = ["DB::set_v1"]
  ; ins = []
  ; p = [par "val" TObj; par "key" TStr; par "table" TDB]
  ; r = TObj
  ; d = "Upsert `val` into `table`, accessible by `key`"
  ; f = InProcess
        (function
          | (state, [DObj value; DStr key; DDB db]) ->
            ignore (User_db.set ~state ~magic:false ~upsert:true db key value);
            DObj value
          | args -> fail args)
  ; pr = None
  ; ps = false
  ; dep = false
  }
  ;

  { pns = ["DB::get_v1"]
  ; ins = []
  ; p = [par "key" TStr; par "table" TDB]
  ; r = TOption
  ; d = "Finds a value in `table` by `key"
  ; f = InProcess
        (function
          | (state, [DStr key; DDB db]) ->
            (try
               DOption (OptJust (User_db.get ~state ~magic:false db key))
             with
             | Exception.DarkException e when e.tipe = Exception.DarkStorage ->
               DOption OptNothing
             | e -> raise e)
          | args -> fail args)
  ; pr = None
  ; ps = true
  ; dep = false
  }
  ;

  { pns = ["DB::getMany_v1"]
  ; ins = []
  ; p = [par "keys" TList; par "table" TDB]
  ; r = TList
  ; d = "Finds many values in `table` by `keys, returning a [[key, value]] list of lists"
  ; f = InProcess
        (function
          | (state, [DList keys; DDB db]) ->
            let skeys =
              List.map
                ~f:(function
                    | DStr s -> s
                    | t ->
                      Exception.user
                        "Expected a string, got: "
                        ^ (t |> Dval.tipe_of |> Dval.tipe_to_string))
                keys
            in
            User_db.get_many ~state ~magic:false db skeys
          | args -> fail args)
  ; pr = None
  ; ps = true
  ; dep = false
  }
  ;

  { pns = ["DB::delete_v1"]
  ; ins = []
  ; p = [par "key" TStr; par "table" TDB]
  ; r = TNull
  ; d = "Delete `key` from `table`"
  ; f = InProcess
        (function
          | (state, [DStr key; DDB db]) ->
            User_db.delete ~state db key;
            DNull
          | args -> fail args)
  ; pr = None
  ; ps = false
  ; dep = false
  }
  ;

  { pns = ["DB::deleteAll_v1"]
  ; ins = []
  ; p = [par "table" TDB]
  ; r = TNull
  ; d = "Delete everything from `table`"
  ; f = InProcess
        (function
          | (state, [DDB db]) ->
            User_db.delete_all state db;
            DNull
          | args -> fail args)
  ; pr = None
  ; ps = false
  ; dep = false
  }
  ;

  { pns = ["DB::query_v1"]
  ; ins = []
  ; p = [par "spec" TObj; par "table" TDB]
  ; r = TList
  ; d = "Fetch all the values from `table` which have the same fields and values that `spec` has
        , returning a [[key, value]] list of lists"
  ; f = InProcess
        (function
          | (state, [DObj map; DDB db]) ->
            map
            |> DvalMap.to_alist
            |> User_db.query ~state ~magic:false db
          | args -> fail args)
  ; pr = None
  ; ps = true
  ; dep = false
  }
  ;

  { pns = ["DB::getAll_v1"]
  ; ins = []
  ; p = [par "table" TDB]
  ; r = TList
  ; d = "Fetch all the values in `table`. Returns a list of lists such that the inner
        lists are pairs of [key, value]. ie. [[key, value], [key, value]]"
  ; f = InProcess
        (function
          | (state, [DDB db]) ->
            User_db.get_all ~state ~magic:false db
          | args -> fail args)
  ; pr = None
  ; ps = true
  ; dep = false
  }
  ;

  (* previously called `DB::keys` *)
  { pns = ["DB::schemaFields_v1"]
  ; ins = []
  ; p = [par "table" TDB]
  ; r = TList
  ; d = "Fetch all the fieldNames in `table`"
  ; f = InProcess
        (function
          | (_, [DDB db]) ->
            User_db.cols_for db
            |> List.map ~f:(fun (k,v) -> DStr k)
            |> DList
          | args -> fail args)
  ; pr = None
  ; ps = true
  ; dep = false
  }
  ;

  { pns = ["DB::schema_v1"]
  ; ins = []
  ; p = [par "table" TDB]
  ; r = TObj
  ; d = "Returns an `Obj` representing { fieldName: fieldType } in `table`"
  ; f = InProcess
        (function
          | (_, [DDB db]) ->
            User_db.cols_for db
            |> List.map ~f:(fun (k,v) -> (k, DStr (Dval.tipe_to_string v)))
            |> Dval.to_dobj
          | args -> fail args)
  ; pr = None
  ; ps = true
  ; dep = false
  }
]