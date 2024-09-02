import Std

import ECS.Family

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
