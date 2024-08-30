import Std

structure Entity where
  id : Nat
  deriving BEq, Hashable, Repr

abbrev System (w a : Type) := ReaderT w IO a

class Elem (s : Type) where
  elemType : Type

class Component (c : Type)  where
  StorageType : Type
  [elemInstance : Elem StorageType]
  constraint : Elem.elemType StorageType = c

class Has (w : Type) (c : Type) [Component c] where
  getStore : System w (Component.StorageType c)

class ExplInit (s : Type) where
  explInit : IO s

class ExplGet (s : Type) [Elem s] where
  explGet : s → Entity → IO (Elem.elemType s)
  explExists : s → Entity → IO Bool

class ExplSet (s : Type) [Elem s] where
  explSet : s → Entity → Elem.elemType s → IO Unit

class ExplDestroy (s : Type) where
  explDestroy : s → Entity → IO Unit

class ExplMembers (s : Type) where
  explMembers : s → IO (Array Entity)

instance [comp : Component c] : Elem (Component.StorageType c) where
  elemType := comp.elemInstance.elemType

-- TODO: Remove requirement to name this instance
instance prodElemInstance [αElem : Elem α] [βElem : Elem β] : Elem (α × β) where
  elemType : Type := αElem.elemType × βElem.elemType

instance [ca : Component α] [cb : Component β] : Component (α × β) where
  StorageType := ca.StorageType × cb.StorageType
  elemInstance : Elem (ca.StorageType × cb.StorageType) := @prodElemInstance _ _ ca.elemInstance cb.elemInstance
  -- TODO: Fix this mess
  constraint :=
    let p : (@Elem.elemType _ (@prodElemInstance _ _ ca.elemInstance cb.elemInstance)) = (ca.elemInstance.elemType × cb.elemInstance.elemType) := rfl
    let p4 : (ca.elemInstance.elemType × cb.elemInstance.elemType) = (α × β) := by
      rw [ca.constraint]
      rw [cb.constraint]
    by
      rw [p]
      rw [p4]

instance [Elem α] [Elem β] [ExplGet α] [ExplGet β] : ExplGet (α × β) where
  explExists s ety := do
    let (sa, sb) := s
    pure ((← ExplGet.explExists sa ety) && (← ExplGet.explExists sb ety))

  explGet s ety := do
    let (sa, sb) := s
    pure ((← ExplGet.explGet sa ety), (← ExplGet.explGet sb ety))

instance [Elem α] [Elem β] [ExplSet α] [ExplSet β] : ExplSet (α × β) where
  explSet s ety a := do
    let (sa, sb) := s
    let (aa, ab) := a
    ExplSet.explSet sa ety aa
    ExplSet.explSet sb ety ab

instance [Elem α] [Elem β] [ExplDestroy α] [ExplDestroy β] : ExplDestroy (α × β) where
  explDestroy s ety := do
    let (sa, sb) := s
    ExplDestroy.explDestroy sa ety
    ExplDestroy.explDestroy sb ety

instance [Elem β] [ExplMembers α] [ExplGet β] : ExplMembers (α × β) where
  explMembers s := do
    let (sa, sb) := s
    let as ← ExplMembers.explMembers sa
    as.filterM (ExplGet.explExists sb)
