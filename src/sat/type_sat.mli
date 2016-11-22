
(** Typechecking of terms from Dolmen.Term.t
    This module provides functions to parse terms from the untyped syntax tree
    defined in Dolmen, and generate formulas as defined in the Expr_sat module. *)

include Type.S with type atom := Expr_sat.t
