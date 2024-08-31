import ECS.Basic
import ECS.Store
import ECS.System

def global : Entity := ⟨0⟩

structure EntityCounter where
  getCounter : Nat

instance : Inhabited EntityCounter where
  default := ⟨1⟩

instance : StorageT EntityCounter where
  storageType := GlobalStorage EntityCounter

instance : Elem (StorageT.storageType EntityCounter) where
  elemType := inferInstanceAs (Elem (GlobalStorage EntityCounter)) |>.elemType

instance : ExplGet (StorageT.storageType EntityCounter) where
  explGet := inferInstanceAs (ExplGet (GlobalStorage EntityCounter)) |>.explGet
  explExists := inferInstanceAs (ExplGet (GlobalStorage EntityCounter)) |>.explExists

instance : ExplSet (StorageT.storageType EntityCounter) where
  explSet := inferInstanceAs (ExplSet (GlobalStorage EntityCounter)) |>.explSet

instance : Component EntityCounter where
  constraint := rfl

def nextEntity
  [Component EntityCounter]
  [Has w EntityCounter]
  [ExplGet (StorageT.storageType EntityCounter)]
  [ExplSet (StorageT.storageType EntityCounter)]
  : System w Entity := do
  let g : EntityCounter ← get global
  set global (EntityCounter.mk (g.getCounter + 1))
  return ⟨g.getCounter⟩

def newEntity
  [StorageT c]
  [Elem (StorageT.storageType c)]
  [Component EntityCounter]
  [Component c]
  [Has w EntityCounter]
  [Has w c]
  [ExplGet (StorageT.storageType EntityCounter)]
  [ExplSet (StorageT.storageType EntityCounter)]
  [ExplSet (StorageT.storageType c)]
  (x : c) : System w Entity := do
  let ety ← nextEntity
  set ety x
  pure ety

def newEntity_
  [StorageT c]
  [Elem (StorageT.storageType c)]
  [Component EntityCounter]
  [Component c]
  [Has w EntityCounter]
  [Has w c]
  [ExplGet (StorageT.storageType EntityCounter)]
  [ExplSet (StorageT.storageType EntityCounter)]
  [ExplSet (StorageT.storageType c)]
  (x : c) : System w Unit := do
  let ety ← nextEntity
  set ety x
