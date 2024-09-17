import Std

import ECS.Family

namespace ECS

structure Entity where
  id : Nat
  deriving BEq, Hashable, Repr

abbrev System (w a : Type) := ReaderT w IO a

opaque StorageFam (c : Type) : Type

opaque ElemFam (s : Type) : Type

class Component (c : Type) {s t : outParam Type} [FamilyDef StorageFam c s] [FamilyDef ElemFam s t] where
  constraint : t = c

class Has (w : Type) (c : Type) {s : outParam Type} [FamilyDef StorageFam c s] where
  getStore : System w s

class ExplInit (s : Type) where
  explInit : IO s

class ExplGet (s : Type) {t : outParam Type} [FamilyDef ElemFam s t] where
  explGet : s → Entity → IO t
  explExists : s → Entity → IO Bool

class ExplSet (s : Type) {t : outParam Type} [FamilyDef ElemFam s t]  where
  explSet : s → Entity → t → IO Unit

class ExplDestroy (s : Type) where
  explDestroy : s → Entity → IO Unit

class ExplMembers (s : Type) where
  explMembers : s → IO (Array Entity)

axiom ProdStorage
  {α β sa sb : Type}
  [FamilyDef StorageFam α sa]
  [FamilyDef StorageFam β sb]
  : StorageFam (α × β) = (sa × sb)
instance
  [FamilyDef StorageFam α sa]
  [FamilyDef StorageFam β sb]
  : (FamilyDef StorageFam (α × β)) (sa × sb) := ⟨ProdStorage⟩

axiom ProdElem
  {α β ea eb : Type}
  [FamilyDef ElemFam α ea]
  [FamilyDef ElemFam β eb]
  : ElemFam (α × β) = (ea × eb)
instance
  [FamilyDef ElemFam α ea]
  [FamilyDef ElemFam β eb]
  : (FamilyDef ElemFam (α × β)) (ea × eb) := ⟨ProdElem⟩

instance
  [FamilyDef StorageFam α sa]
  [FamilyDef StorageFam β sb]
  [FamilyDef ElemFam sa ea]
  [FamilyDef ElemFam sb eb]
  [ca : @Component α sa ea _ _]
  [cb : @Component β sb eb _ _]
  : @Component (α × β) (sa × sb) (ea × eb) _ _ where
  constraint := by
      rw [ca.constraint]
      rw [cb.constraint]

instance
  [FamilyDef ElemFam α ea]
  [FamilyDef ElemFam β eb]
  [@ExplGet α ea _]
  [@ExplGet β eb _]
  : @ExplGet (α × β) (ea × eb) _ where
  explExists s ety := do
    let (sa, sb) := s
    pure ((← ExplGet.explExists sa ety) && (← ExplGet.explExists sb ety))

  explGet s ety := do
    let (sa, sb) := s
    pure ((← ExplGet.explGet sa ety), (← ExplGet.explGet sb ety))

instance
  [FamilyDef ElemFam α ea]
  [FamilyDef ElemFam β eb]
  [@ExplSet α ea _]
  [@ExplSet β eb _]
  : @ExplSet (α × β) (ea × eb) _ where
  explSet s ety a := do
    let (sa, sb) := s
    let (aa, ab) := a
    ExplSet.explSet sa ety aa
    ExplSet.explSet sb ety ab

instance [ExplDestroy α] [ExplDestroy β] : ExplDestroy (α × β) where
  explDestroy s ety := do
    let (sa, sb) := s
    ExplDestroy.explDestroy sa ety
    ExplDestroy.explDestroy sb ety

instance [FamilyDef ElemFam β eb] [ExplMembers α] [@ExplGet β eb _] : ExplMembers (α × β) where
  explMembers s := do
    let (sa, sb) := s
    let as ← ExplMembers.explMembers sa
    as.filterM (ExplGet.explExists sb)

instance
  [FamilyDef StorageFam α sa]
  [FamilyDef StorageFam β sb]
  [@Has w α sa _]
  [@Has w β sb _]
  : @Has w (α × β) (sa × sb) _ where
  getStore := do
    let sta : sa ← Has.getStore α
    let stb : sb ← Has.getStore β
    pure (sta, stb)


/--
A pseudocomponent indicating the absence of α

Can be used as:

  cmap (fun (a, Not b) => c)

to iterate over entities with an `a` but no `b`

It can also be used as:

  cmap (fun a => Not : Not a)

to delete every `a` component.
--/
inductive Not (α : Type) :=
  | Not


/--
A pseudostore used to produce values of `Not a`. It inverts `explExists` and destroys instead of `explSet`
--/
structure NotStore (α : Type) where
  val : α

axiom ElemNotStore {s es : Type} [FamilyDef ElemFam s es] : ElemFam (NotStore s) = Not es
instance [FamilyDef ElemFam s es] : FamilyDef ElemFam (NotStore s) (Not es) := ⟨ElemNotStore⟩

axiom StorageNot {c s : Type} [FamilyDef StorageFam c s] : StorageFam (Not c) = NotStore s
instance [FamilyDef StorageFam c s] : FamilyDef StorageFam (Not c) (NotStore s) := ⟨StorageNot⟩

instance
  [FamilyDef StorageFam c s]
  [FamilyDef ElemFam s es]
  [ca : @Component c s es _ _]
  : @Component (Not c) (NotStore s) (Not es) _ _ where
  constraint := congrArg Not ca.constraint

instance
  [FamilyDef StorageFam c s]
  [@Has w c s _]
  : @Has w (Not c) (NotStore s) _ where
  getStore := NotStore.mk <$> Has.getStore c

instance
  [FamilyDef ElemFam s e]
  [@ExplGet s e _]
  : @ExplGet (NotStore s) (Not e) _ where
  explGet _ _ := pure .Not
  explExists sa ety := do
    let (NotStore.mk st) := sa
    not <$> ExplGet.explExists st ety

instance
  [FamilyDef ElemFam s e]
  [ExplDestroy s] : @ExplSet (NotStore s) (Not e) _ where
  explSet sa ety _ := do
    let (NotStore.mk st) := sa
    ExplDestroy.explDestroy st ety

/-- A pseudostore used to produce values of type `Option a`. It will always return `true` for `explExists`.
Writing can both set and delete a component using `some` and `none` respectively.
--/
structure OptionStore (α : Type) where
  val : α

axiom ElemOptionStore {s es : Type} [FamilyDef ElemFam s es] : ElemFam (OptionStore s) = Option es
instance [FamilyDef ElemFam s es] : FamilyDef ElemFam (OptionStore s) (Option es) := ⟨ElemOptionStore⟩

axiom StorageOption {c s : Type} [FamilyDef StorageFam c s] : StorageFam (Option c) = OptionStore s
instance [FamilyDef StorageFam c s] : FamilyDef StorageFam (Option c) (OptionStore s) := ⟨StorageOption⟩

instance
  [FamilyDef StorageFam c s]
  [FamilyDef ElemFam s es]
  [ca : @Component c s es _ _]
  : @Component (Option c) (OptionStore s) (Option es) _ _ where
  constraint := congrArg Option ca.constraint

instance
  [FamilyDef StorageFam c s]
  [@Has w c s _]
  : @Has w (Option c) (OptionStore s) _ where
  getStore := OptionStore.mk <$> Has.getStore c

instance
  [FamilyDef ElemFam s e]
  [@ExplGet s e _]
  : @ExplGet (OptionStore s) (Option e) _ where
  explGet sa ety := do
    let (OptionStore.mk st) := sa
    if (← ExplGet.explExists st ety)
      then some <$> ExplGet.explGet st ety
      else return none

  explExists _ _ := return true

instance
  [FamilyDef ElemFam s e]
  [ExplDestroy s]
  [@ExplSet s e _]
  : @ExplSet (OptionStore s) (Option e) _ where
    explSet sa ety mv := do
      let (OptionStore.mk st) := sa
      match mv with
        | none => ExplDestroy.explDestroy st ety
        | some x => ExplSet.explSet st ety x

/-- Instances for Unit.
Useful when you want to 'do nothing' in a cmap
--/
axiom ElemUnitStore : ElemFam Unit = Unit
instance : FamilyDef ElemFam Unit Unit := ⟨ElemUnitStore⟩

axiom StorageUnit : StorageFam Unit = Unit
instance : FamilyDef StorageFam Unit Unit := ⟨StorageUnit⟩

instance : @Component Unit Unit Unit _ _ where
  constraint := rfl

instance : @Has w Unit Unit _ where
  getStore := return ()

instance : @ExplGet Unit Unit _ where
  explGet _ _ := return ()
  explExists _ _ := return true

instance : @ExplSet Unit Unit _ where
  explSet _ _ _ := return ()

instance : ExplDestroy Unit where
  explDestroy _ _ := return ()
