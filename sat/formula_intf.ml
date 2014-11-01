(**************************************************************************)
(*                                                                        *)
(*                                  Cubicle                               *)
(*             Combining model checking algorithms and SMT solvers        *)
(*                                                                        *)
(*                  Guillaume Bury                                        *)
(*                  INRIA                                                 *)
(*                  Sylvain Conchon and Alain Mebsout                     *)
(*                  Universite Paris-Sud 11                               *)
(*                                                                        *)
(*  Copyright 2011. This file is distributed under the terms of the       *)
(*  Apache Software License version 2.0                                   *)
(*                                                                        *)
(**************************************************************************)

module type S = sig

  type t
  (** The type of atomic formulas. *)

  val true_ : t
  val false_ : t
  val dummy : t
  (** Formula constants. [dummy] should be different from any other formula. *)

  val neg : t -> t
  (** Formula negation *)

  val norm : t -> t * bool
  (** Returns a 'normalized' form of the formula, possibly negated (in which case return true).
      Note : [fun a -> a, false] is a perfectly reasonnable implementation. *)

  val hash : t -> int
  val equal : t -> t -> bool
  val compare : t -> t -> int
  (** Usual hash and comparison functions. Given to Map and Hash functors. *)

  val label : t -> Hstring.t
  val add_label : Hstring.t -> t -> unit
  (** Optional. Not yet used in Solver. *)

  val print : Format.formatter -> t -> unit
  (** Printing function used for debugging. *)
end
