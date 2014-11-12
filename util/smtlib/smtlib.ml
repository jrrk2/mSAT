(* Copyright 2014 INRIA **)

open Smtlib_syntax

module F = Sat.Fsat
module T = Sat.Tseitin

exception Bad_arity of string
exception Unknown_command
exception Incomplete_translation

(* Environment *)
let env : (string, T.t) Hashtbl.t = Hashtbl.create 57;;
Hashtbl.add env "true" T.f_true;;
Hashtbl.add env "false" T.f_false;;

let get_var =
    fun s ->
        try
            Hashtbl.find env s
        with Not_found ->
            let f = T.make_atom (F.fresh ()) in
            Hashtbl.add env s f;
            f

(* Term translation *)
let translate_const = function
    | SpecConstsDec(_, s)
    | SpecConstNum(_, s)
    | SpecConstString(_, s)
    | SpecConstsHex(_, s)
    | SpecConstsBinary(_, s) -> get_var s

let translate_symbol = function
    | Symbol(_, s)
    | SymbolWithOr(_, s) -> s

let translate_id = function
    | IdSymbol(_, s) -> translate_symbol s
    | IdUnderscoreSymNum(_, s, n) -> raise Incomplete_translation

let translate_sort = function
    | SortIdentifier(_, id) ->
            let s = translate_id id in
            if s <> "Bool" then raise Incomplete_translation
    | _ -> raise Incomplete_translation

let translate_qualid = function
    | QualIdentifierId(_, id) -> translate_id id
    | QualIdentifierAs(_, id, s) -> raise Incomplete_translation

let left_assoc s f = function
    | x :: r -> List.fold_left f x r
    | _ -> raise (Bad_arity s)

let right_assoc s f = function
    | x :: r -> List.fold_right f r x
    | _ -> raise (Bad_arity s)

let rec translate_term = function
    | TermSpecConst(_, const) -> translate_const const
    | TermQualIdentifier(_, id) -> get_var (translate_qualid id)
    | TermQualIdTerm(_, f, (_, l)) ->
            begin match (translate_qualid f), (List.map translate_term l) with
            (* CORE theory translation - '=', 'distinct','ite' not yet implemented *)
            | "not", [e] -> T.make_not e
            | "not", _ -> raise (Bad_arity "not")
            | "and" as s, l -> T.make_and l
            | "or" as s, l -> T.make_or l
            | "xor" as s, l -> left_assoc s T.make_xor l
            | "=>" as s, l -> right_assoc s T.make_imply l
            | _ -> raise Unknown_command
            end
    | _ -> raise Incomplete_translation

(* Command Translation *)
let translate_command = function
    | CommandDeclareFun(_, s, (_, []), ret) ->
            ignore (translate_sort ret);
            ignore (get_var (translate_symbol s));
            None
    | CommandAssert(_, t) ->
            Some (translate_term t)
    | _ -> None

let rec translate_command_list acc = function
    | [] -> acc
    | c :: r ->
                begin match translate_command c with
                | None -> translate_command_list acc r
                | Some t -> translate_command_list (t :: acc) r
                end

let translate = function
    | Some Commands (_, (_, l)) -> List.rev (translate_command_list [] l)
    | None -> []

let parse file =
    let f = open_in file in
    let lexbuf = Lexing.from_channel f in
    let commands = Parsesmtlib.main Lexsmtlib.token lexbuf in
    close_in f;
    translate commands