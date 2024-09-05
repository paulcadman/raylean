import Std

import ECS.Basic
import ECS.Family

namespace ECS

structure MapStorage (c : Type) where
  ref : IO.Ref (Std.HashMap Entity c)

namespace MapStorage

def init : IO (MapStorage c) := MapStorage.mk <$> IO.mkRef (Std.HashMap.empty)

def get (s : MapStorage c) (e : Entity) : IO c := do
  let st <- s.ref.get
  match Std.HashMap.get? st e with
   | (some x) => pure x
   | none => panic! "Reading non-existent component"

def exists? (s : MapStorage c) (e : Entity) : IO Bool :=
  (Std.HashMap.contains · e) <$> s.ref.get

def set (s : MapStorage c) (e : Entity) (x : c) : IO Unit := do
  let m ← s.ref.get
  Std.HashMap.insert m e x |> s.ref.set

def destroy (s : MapStorage c) (e : Entity) : IO Unit := do
  let m ← s.ref.get
  Std.HashMap.erase m e |> s.ref.set

def members (s : MapStorage c) : IO (Array Entity) :=
  Std.HashMap.keysArray <$> s.ref.get

axiom ElemMapStorage : {c : Type} → ElemFam (MapStorage c) = c
instance : FamilyDef ElemFam (MapStorage c) c := ⟨ElemMapStorage⟩

instance : ExplInit (MapStorage c) where
  explInit := init

instance : @ExplGet (MapStorage c) c _ where
  explGet := get
  explExists := exists?

instance : @ExplSet (MapStorage c) c _ where
  explSet := set

instance : ExplDestroy (MapStorage c) where
  explDestroy := destroy

instance : ExplMembers (MapStorage c) where
  explMembers := members

class StorageMapping

end MapStorage

structure GlobalStorage (α : Type) where
 ref : IO.Ref α

namespace GlobalStorage

axiom ElemGlobalStorage : {c : Type} → ElemFam (GlobalStorage c) = c
instance : FamilyDef ElemFam (GlobalStorage c) c := ⟨ElemGlobalStorage⟩

instance [Inhabited α] : ExplInit (GlobalStorage α) where
  explInit := GlobalStorage.mk <$> IO.mkRef default

instance explGetGlobal : @ExplGet (GlobalStorage α) α _ where
  explGet s _ := s.ref.get
  explExists _ _ := pure true

instance : @ExplSet (GlobalStorage α) α _ where
  explSet s _ a := s.ref.set a

end GlobalStorage

structure UniqueStorage (α : Type) where
  ref : IO.Ref (Option (Entity × α))

axiom ElemUniqueStorage : {c : Type} → ElemFam (UniqueStorage c) = c
instance : FamilyDef ElemFam (UniqueStorage c) c := ⟨ElemUniqueStorage⟩

namespace UniqueStorage

instance : ExplInit (UniqueStorage α) where
  explInit := UniqueStorage.mk <$> IO.mkRef none

instance : @ExplGet (UniqueStorage α) α _ where
  explGet s _ := do
    let u ← s.ref.get
    match u with
    | (some (_, c)) => pure c
    | none => panic! "Reading non-existent unique component"

  explExists s e := do
    let u ← s.ref.get
    pure <| match u with
            | (some (ety, _)) => e == ety
            | none => false

instance : @ExplSet (UniqueStorage α) α _ where
  explSet s ety c := s.ref.set (some (ety, c))

instance : ExplDestroy (UniqueStorage α) where
  explDestroy s e := do
    let u ← s.ref.get
    match u with
        | (some (ety, _)) => if (ety == e) then s.ref.set none else pure Unit.unit
        | none => pure Unit.unit

instance : ExplMembers (UniqueStorage α) where
  explMembers s := do
    let u ← s.ref.get
    pure <| match u with
        | none => #[]
        | (some (ety, _)) => #[ety]

end UniqueStorage
