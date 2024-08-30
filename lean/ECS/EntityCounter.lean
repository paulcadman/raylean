import ECS.Basic
import ECS.Store
import ECS.System

def global : Entity := ⟨0⟩

structure EntityCounter where
  getCounter : Nat

instance : Inhabited EntityCounter where
  default := ⟨1⟩

instance : Component EntityCounter where
  StorageType := GlobalStorage EntityCounter
  constraint := rfl

def nextEntity
  [comp : Component EntityCounter]
  [Has w EntityCounter]
  [ExplGet comp.StorageType]
  [ExplSet comp.StorageType]
  : System w Entity := do
  let g : EntityCounter ← get global
  set global (EntityCounter.mk (g.getCounter + 1))
  return ⟨g.getCounter⟩

def newEntity
  [eComp : Component EntityCounter]
  [cComp : Component c]
  [Has w EntityCounter]
  [Has w c]
  [ExplGet eComp.StorageType]
  [ExplSet eComp.StorageType]
  [ExplSet cComp.StorageType]
  (x : c) : System w Entity := do
  let ety ← nextEntity
  set ety x
  pure ety

def newEntity_
  [eComp : Component EntityCounter]
  [cComp : Component c]
  [Has w EntityCounter]
  [Has w c]
  [ExplGet eComp.StorageType]
  [ExplSet eComp.StorageType]
  [ExplSet cComp.StorageType]
  (x : c) : System w Unit := do
  let ety ← nextEntity
  set ety x
