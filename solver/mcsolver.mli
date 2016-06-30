(*
MSAT is free software, using the Apache license, see file LICENSE
Copyright 2014 Guillaume Bury
Copyright 2014 Simon Cruanes
*)

module type S = Solver_intf.S

module Make (E : Expr_intf.S)
    (Th : Plugin_intf.S with type term = E.Term.t
                         and type formula = E.Formula.t
                         and type proof = E.proof)
    (Dummy: sig end) :
  S with type St.term = E.Term.t
     and type St.formula = E.Formula.t
     and type St.proof = E.proof
(** Functor to create a solver parametrised by the atomic formulas and a theory. *)

