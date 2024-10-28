import ECS.Basic
import ECS.Store
import ECS.System

namespace ECS

structure EntityCounter where
  getCounter : Nat
  deriving Inhabited

axiom StorageEntityCounter : StorageFam EntityCounter = GlobalStorage EntityCounter
instance : FamilyDef StorageFam EntityCounter (GlobalStorage EntityCounter) := ⟨StorageEntityCounter⟩

instance : @Component EntityCounter (GlobalStorage EntityCounter) EntityCounter _ _ where
  constraint := rfl

def nextEntity
  [@Has w EntityCounter (GlobalStorage EntityCounter) _]
  : System w Entity := do
  let g : EntityCounter ← getGlobal
  setGlobal (EntityCounter.mk (g.getCounter + 1))
  return ⟨g.getCounter⟩

def newEntity
  [FamilyDef StorageFam c s]
  [FamilyDef ElemFam s t]
  [@Component c s t _ _]
  [@Has w EntityCounter (GlobalStorage EntityCounter) _]
  [@Has w c s _]
  [@ExplSet s t _]
  (x : c) : System w Entity := do
  let ety ← nextEntity
  set' ety x
  pure ety

def newEntity_
  [FamilyDef StorageFam c s]
  [FamilyDef ElemFam s t]
  [@Component c s t _ _]
  [@Has w EntityCounter (GlobalStorage EntityCounter) _]
  [@Has w c s _]
  [@ExplSet s t _]
  (x : c) : System w Unit := do
  let ety ← nextEntity
  set' ety x

def newEntityAs_
  (c : Type)
  [FamilyDef StorageFam c s]
  [FamilyDef ElemFam s t]
  [@Component c s t _ _]
  [@Has w EntityCounter (GlobalStorage EntityCounter) _]
  [@Has w c s _]
  [@ExplSet s t _]
  (x : c) : System w Unit := do
  let ety ← nextEntity
  set' ety x
