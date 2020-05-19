Require Import Cava.Arrow.Arrow.

Section WithArrow.
  Variable arr: Arrow.

  Section Vars.
    Variable var: object -> object -> Type.

    Inductive kappa_sugared : object -> object -> Type :=
    | Var: forall x y,    var x y -> kappa_sugared x y
    | Abs: forall x y z,  (var unit x -> kappa_sugared y z) -> kappa_sugared (x**y) z
    | App: forall x y z,  kappa_sugared (x**y) z -> kappa_sugared unit x -> kappa_sugared y z
    | Com: forall x y z,  kappa_sugared y z -> kappa_sugared x y -> kappa_sugared x z
    | Arr: forall x y,    morphism x y -> kappa_sugared x y
    | Let: forall x y z,  kappa_sugared unit x -> (var unit x -> kappa_sugared y z) -> kappa_sugared y z.

    Inductive kappa : object -> object -> Type :=
    | DVar : forall x y,   var x y -> kappa x y
    | DAbs : forall x y z, (var unit x -> kappa y z) -> kappa (x**y) z
    | DApp : forall x y z, kappa (x**y) z -> kappa unit x -> kappa y z
    | DCompose : forall x y z, kappa y z -> kappa x y -> kappa x z
    | DArr : forall x y,   morphism x y -> kappa x y.
  End Vars.

  Arguments Var [var x y].
  Arguments Abs [var x y z].
  Arguments App [var x y z].
  Arguments Com [var x y z].
  Arguments Arr [var x y].
  Arguments Let [var x y z].

  Arguments DVar [var x y].
  Arguments DAbs [var x y z].
  Arguments DApp [var x y z].
  Arguments DCompose [var x y z].
  Arguments DArr [var x y].

  Definition Kappa_sugared i o := forall var, @kappa_sugared var i o.
  Definition Kappa i o := forall var, @kappa var i o.

  (* desugars let bindings *)
  Fixpoint desugar {var i o} (e: kappa_sugared var i o) : kappa var i o :=
  match e with
  | Var x => DVar x
  | Abs f => DAbs (fun x => desugar (f x))
  | App e1 e2 => DApp (desugar e1) (desugar e2)
  | Com f g => DCompose (desugar f) (desugar g)
  | Arr m => DArr m
  | Let x f => DApp (DAbs (fun x => desugar (f x))) (desugar x)
  end.

  Definition Desugar {i o} (e: Kappa_sugared i o) : Kappa i o := fun var => desugar (e var).

  (* reproject into unsugared into kappa *)
  Fixpoint kappa_project {var i o} (e: kappa var i o) : kappa_sugared var i o :=
  match e with
  | DVar x => Var x
  | DAbs f => Abs (fun x => kappa_project (f x))
  | DApp e1 e2 => App (kappa_project e1) (kappa_project e2)
  | DCompose f g => Com (kappa_project f) (kappa_project g)
  | DArr m => Arr m
  end.

End WithArrow.

Arguments Var [arr var x y].
Arguments Abs [arr var x y z].
Arguments App [arr var x y z].
Arguments Com [arr var x y z].
Arguments Arr [arr var x y].
Arguments Let [arr var x y z].

Arguments DVar [arr var x y].
Arguments DAbs [arr var x y z].
Arguments DApp [arr var x y z].
Arguments DCompose [arr var x y z].
Arguments DArr [arr var x y].

Arguments kappa [arr].
Arguments Kappa [arr].

Arguments kappa_sugared [arr].
Arguments Kappa_sugared [arr].