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

