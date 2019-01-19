(*
MSAT is free software, using the Apache license, see file LICENSE
Copyright 2016 Guillaume Bury
*)

(** Sat solver

    This modules instanciates a pure sat solver using integers to represent
    atomic propositions.
*)

module Expr = Expr_sat

include Msat.S with type Formula.t = Expr.t and type theory = unit
(** A functor that can generate as many solvers as needed. *)

