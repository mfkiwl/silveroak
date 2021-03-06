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

From Coq Require Import Lists.List.
From Coq Require Import Strings.Ascii Strings.String Vectors.Vector.
From Coq Require Import NArith.
Import ListNotations.
Import VectorNotations.

Require Import ExtLib.Structures.Monads.
Export MonadNotation.

Require Import Cava.Cava.
Require Import Cava.Acorn.Acorn.
Require Import Cava.Lib.UnsignedAdders.
Require Import Coq.Vectors.Vector.
Require Import Cava.VectorUtils.
Require Import Coq.Bool.Bvector.

From Coq Require Import Bool.Bvector.

Section WithCava.
  Context `{CavaSeq}.

  Definition bitvec_to_signal {n : nat} (lut : Vector.t bool n) : signal (Vec Bit n) :=
    unpeel (Vector.map constant lut).
  Search (nat -> Bvector _).

  Definition array : signal (Vec (Vec Bit 8) 4) :=
    unpeel (map (fun x => bitvec_to_signal (nat_to_bitvec_sized _ x)) [0;1;2;3]).

  Definition multiDimArray : signal (Vec (Vec (Vec Bit 8) 4) 2) :=
    unpeel ([array; array]).

  Definition arrayTest (i : signal (Vec Bit 8))
                       : cava (signal (Vec Bit 8)) :=
    ret (indexConst array 0).

  Definition multiDimArrayTest (i : signal (Vec Bit 8))
                       : cava (signal (Vec Bit 8)) :=
    let v := indexConst multiDimArray 0 in
    ret (indexConst v 0).

End WithCava.

Local Open Scope list_scope.

Definition arrayTest_Interface
  := sequentialInterface "arrayTest"
     "clk" PositiveEdge "rst" PositiveEdge
     [mkPort "i" (Vec Bit 8)]
     [mkPort "o" (Vec Bit 8)]
     [].

Definition multiDimArrayTest_Interface
  := sequentialInterface "multiDimArrayTest"
     "clk" PositiveEdge "rst" PositiveEdge
     [mkPort "i" (Vec Bit 8)]
     [mkPort "o" (Vec Bit 8)]
     [].

Definition arrayTest_Netlist := makeNetlist arrayTest_Interface arrayTest.
Definition multiDimArrayTest_Netlist := makeNetlist multiDimArrayTest_Interface multiDimArrayTest.

Definition arrayTest_tb_inputs := List.repeat (nat_to_bitvec_sized 8 0) 2.

Definition arrayTest_tb_expected_outputs
  := sequential (arrayTest arrayTest_tb_inputs).
Definition multiDimArrayTest_tb_expected_outputs
  := sequential (multiDimArrayTest arrayTest_tb_inputs).

Definition arrayTest_tb
  := testBench "arrayTest_tb" arrayTest_Interface
      arrayTest_tb_inputs arrayTest_tb_expected_outputs.
Definition multiDimArrayTest_tb
  := testBench "multiDimArrayTest_tb" multiDimArrayTest_Interface
      arrayTest_tb_inputs multiDimArrayTest_tb_expected_outputs.
