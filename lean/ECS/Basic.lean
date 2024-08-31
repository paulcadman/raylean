import Std

structure Entity where
  id : Nat
  deriving BEq, Hashable, Repr

abbrev System (w a : Type) := ReaderT w IO a

class Elem (s : Type) where
  elemType : Type

class StorageT (α : Type) where
  storageType : Type

class Component (c : Type) [st : StorageT c] [Elem st.storageType] where
  constraint : Elem.elemType st.storageType = c

class Has (w : Type) (c : Type) [StorageT c] where
  getStore : System w (StorageT.storageType c)

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

instance [sa : StorageT α] [sb : StorageT β] : StorageT (α × β) where
  storageType := sa.storageType × sb.storageType

instance [StorageT α] [StorageT β] [ea : Elem (StorageT.storageType α)] [eb : Elem (StorageT.storageType β)] : Elem (StorageT.storageType (α × β)) where
  elemType := ea.elemType × eb.elemType

instance [ea : Elem α] [eb : Elem β] : Elem (α × β) where
  elemType := ea.elemType × eb.elemType

instance [sa : StorageT α] [sb : StorageT β] [ea : Elem sa.storageType] [eb : Elem sb.storageType] [ca : Component α] [cb : Component β] : Component (α × β) where
  constraint :=
    let p1 : Elem (StorageT.storageType (α × β)) := inferInstance
    let p2 : p1.elemType = (ea.elemType × eb.elemType) := rfl
    let p3 : (ea.elemType × eb.elemType) = (α × β) := by
      rw [ca.constraint]
      rw [cb.constraint]
    by
      rw [p2]
      rw [p3]

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

instance [StorageT α] [StorageT β] [Elem (StorageT.storageType α)] [Elem (StorageT.storageType β)] [Component α] [Component β] [Has w α] [Has w β] : Has w (α × β) where
  getStore := do
    pure ((← Has.getStore), (← Has.getStore))
