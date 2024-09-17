import ECS.Family
import ECS.Basic

namespace ECS

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

/-- An `Sum` component, a logical disjunction between two components.
-- Getting an `a ⊕ b` will first attempt to get a `b` and return it as `inr b`, or if it does not exist, get an `a` as `inl a`.
-- Can also be used to set one of two things.
--/
structure SumStore (sa sb : Type) where
  sta : sa
  stb : sb

axiom ElemSumStore
  {sa sb ea eb : Type}
  [FamilyDef ElemFam sa ea]
  [FamilyDef ElemFam sb eb]
  : ElemFam (SumStore sa sb) = (ea ⊕ eb)
instance
  {sa sb ea eb : Type}
  [FamilyDef ElemFam sa ea]
  [FamilyDef ElemFam sb eb]
  : FamilyDef ElemFam (SumStore sa sb) (ea ⊕ eb) := ⟨ElemSumStore⟩

axiom StorageSum
  {ca cb sa sb : Type}
  [FamilyDef StorageFam ca sa]
  [FamilyDef StorageFam cb sb]
  : StorageFam (ca ⊕ cb) = SumStore sa sb
instance
  {ca cb sa sb : Type}
  [FamilyDef StorageFam ca sa]
  [FamilyDef StorageFam cb sb]
  : FamilyDef StorageFam (ca ⊕ cb) (SumStore sa sb) := ⟨StorageSum⟩

instance
  [FamilyDef StorageFam ca sa]
  [FamilyDef StorageFam cb sb]
  [FamilyDef ElemFam sa ea]
  [FamilyDef ElemFam sb eb]
  [compA : @Component ca sa ea _ _]
  [compB : @Component cb sb eb _ _]
  : @Component (ca ⊕ cb) (SumStore sa sb) (ea ⊕ eb) _ _ where
    constraint := by
      rw [compA.constraint]
      rw [compB.constraint]

instance
  [FamilyDef StorageFam ca sa]
  [FamilyDef StorageFam cb sb]
  [@Has w ca sa _]
  [@Has w cb sb _]
  : @Has w (ca ⊕ cb) (SumStore sa sb) _ where
    getStore := do
      let sta ← Has.getStore ca
      let stb ← Has.getStore cb
      return (SumStore.mk sta stb)

instance
  [FamilyDef ElemFam sa ea]
  [FamilyDef ElemFam sb eb]
  [@ExplGet sa ea _]
  [@ExplGet sb eb _]
  : @ExplGet (SumStore sa sb) (ea ⊕ eb) _ where
  explGet s ety := do
    let (SumStore.mk sta stb) := s
    if (← ExplGet.explExists stb ety)
      then .inr <$> ExplGet.explGet stb ety
      else .inl <$> ExplGet.explGet sta ety

  explExists s ety := do
    let (SumStore.mk sa sb) := s
    if (← ExplGet.explExists sb ety)
      then return true
      else ExplGet.explExists sa ety

instance
  [FamilyDef ElemFam sa ea]
  [FamilyDef ElemFam sb eb]
  [@ExplSet sa ea _]
  [@ExplSet sb eb _]
  : @ExplSet (SumStore sa sb) (ea ⊕ eb) _ where
  explSet s ety v := do
    let (SumStore.mk sta stb) := s
    match v with
      | .inr b => ExplSet.explSet stb ety b
      | .inl a => ExplSet.explSet sta ety a

instance
  [ExplDestroy sa]
  [ExplDestroy sb]
  : ExplDestroy (SumStore sa sb) where
  explDestroy s ety := do
    let (SumStore.mk sta stb) := s
    ExplDestroy.explDestroy sta ety
    ExplDestroy.explDestroy stb ety

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

/-- A pseudostore used to produce components of type `Entity`.
It always returns `true` for `explExists`, and echoes back the entity argument for `explGet`.
It can be used in e.g. `cmap $ fun (a, ety : Entity) -> b` to access the current entity.
--/
inductive EntityStore where
  | EntityStore

axiom ElemEntityStore : ElemFam EntityStore = Entity
instance : FamilyDef ElemFam EntityStore Entity := ⟨ElemEntityStore⟩

axiom StorageEntity : StorageFam Entity = EntityStore
instance : FamilyDef StorageFam Entity EntityStore := ⟨StorageEntity⟩

instance : @Component Entity EntityStore Entity _ _ where
  constraint := rfl

instance : @Has w Entity EntityStore _ where
  getStore := return .EntityStore

instance : @ExplGet EntityStore Entity _ where
  explGet _ ety := return ety
  explExists _ _ := return true
