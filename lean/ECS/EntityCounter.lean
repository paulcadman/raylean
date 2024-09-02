import ECS.Basic
import ECS.Store
import ECS.System

def global : Entity := ⟨0⟩

structure EntityCounter where
  getCounter : Nat

instance : Inhabited EntityCounter where
  default := ⟨1⟩

axiom StorageEntityCounter : StorageFam EntityCounter = GlobalStorage EntityCounter
instance : FamilyDef StorageFam EntityCounter (GlobalStorage EntityCounter) := ⟨StorageEntityCounter⟩

instance : @Component EntityCounter (GlobalStorage EntityCounter) EntityCounter _ _ where
  constraint := rfl

def nextEntity
  [FamilyDef StorageFam EntityCounter s]
  [FamilyDef ElemFam s t]
  [@Component EntityCounter s t _ _]
  [@Has w EntityCounter s _]
  [@ExplGet s t _]
  [@ExplSet s t _]
  : System w Entity := do
  let g : EntityCounter ← get global
  set' global (EntityCounter.mk (g.getCounter + 1))
  return ⟨g.getCounter⟩

def newEntity
  [FamilyDef StorageFam c s]
  [FamilyDef ElemFam s t]
  [FamilyDef StorageFam EntityCounter se]
  [FamilyDef ElemFam se te]
  [@Component c s t _ _]
  [@Component EntityCounter se te _ _]
  [@Has w EntityCounter se _]
  [@Has w c s _]
  [@ExplGet se te _]
  [@ExplSet se te _]
  [@ExplSet s t _]
  (x : c) : System w Entity := do
  let ety ← nextEntity
  set' ety x
  pure ety

def newEntity_
  [FamilyDef StorageFam c s]
  [FamilyDef ElemFam s t]
  [FamilyDef StorageFam EntityCounter se]
  [FamilyDef ElemFam se te]
  [@Component c s t _ _]
  [@Component EntityCounter se te _ _]
  [@Has w EntityCounter se _]
  [@Has w c s _]
  [@ExplGet se te _]
  [@ExplSet se te _]
  [@ExplSet s t _]
  (x : c) : System w Unit := do
  let ety ← nextEntity
  set' ety x
