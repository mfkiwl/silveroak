(****************************************************************************)
(* Copyright 2020 The Project Oak Authors                                   *)
(*                                                                          *)
(* Licensed under the Apache License, Version 2.0 (the "License")           *)
(* you may not use this file except in compliance with the License.         *)
(* You may obtain a copy of the License at                                  *)
(*                                                                          *)
(*     http://www.apache.org/licenses/LICENSE-2.0                           *)
(*                                                                          *)
(* Unless required by applicable law or agreed to in writing, software      *)
(* distributed under the License is distributed on an "AS IS" BASIS,        *)
(* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *)
(* See the License for the specific language governing permissions and      *)
(* limitations under the License.                                           *)
(****************************************************************************)

From Coq Require Import Strings.Ascii Strings.String.
From Coq Require Import NArith.NArith Lists.List.
Import ListNotations.

Require Import ExtLib.Structures.Monads.
Export MonadNotation.

Require Import Cava.Cava.
Require Import Cava.Tactics.
Require Import Cava.Acorn.Acorn.
Require Import Cava.Lib.UnsignedAdders.

(******************************************************************************)
(* countBy                                                                    *)
(******************************************************************************) 

(*

The countBy circuit takes the current 8-bit input (in) and the current
state value represented by the register (delay) which is output in the
current cycle as the output of the circuit, and this value is also the
next state value for the delay. The adder is an 8-bit adder with no
bit-growth i.e. it computes (a + b) mod 256.

        _______
    ---| delay |------------
   |   |_______|            |
   |   ___                  |
    --| + ---------------------- out
 in --|___|

*)

Section WithCava.
  Context {signal} {combsemantics: Cava signal}
          {semantics: CavaSeq combsemantics}.

  Definition countBy : signal (Vec Bit 8) -> cava (signal (Vec Bit 8))
    := loopDelayS addN.

End WithCava.

(* Convenience notations for certain bytes *)
Definition b0 := N2Bv_sized 8 0.
Definition b3 := N2Bv_sized 8 3.
Definition b7 := N2Bv_sized 8 7.
Definition b14 := N2Bv_sized 8 14.
Definition b18 := N2Bv_sized 8 18.
Definition b21 := N2Bv_sized 8 21.
Definition b24 := N2Bv_sized 8 24.
Definition b250 := N2Bv_sized 8 250.

Local Open Scope list_scope.

Example countBy_ex1: sequential (countBy [b14; b7; b3; b250]) = [b14; b21; b24; b18].
Proof. reflexivity. Qed.

Definition countBy_Interface
  := sequentialInterface "countBy"
     "clk" PositiveEdge "rst" PositiveEdge
     [mkPort "i" (Vec Bit 8)]
     [mkPort "o" (Vec Bit 8)]
     [].

Definition countBy_Netlist := makeNetlist countBy_Interface countBy.

Definition countBy_tb_inputs
  := [b14; b7; b3; b250].

Definition countBy_tb_expected_inputs := sequential (countBy countBy_tb_inputs).

Definition countBy_tb
  := testBench "countBy_tb" countBy_Interface
     countBy_tb_inputs countBy_tb_expected_inputs.
