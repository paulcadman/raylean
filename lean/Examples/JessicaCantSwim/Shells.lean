import Std
import Examples.JessicaCantSwim.Rand
import Examples.JessicaCantSwim.Types

namespace Shells

structure Shell where
  private id: Nat
  private position : Shape.Vector2
  private radius: Float

def Shell.init (id: Nat) (position: Shape.Vector2): Shell :=
  {
    id := id,
    position := position,
    radius := 5,
  }

def Shell.bounds (s: Shell): List Shape.Rectangle :=
  [{
    x := s.position.x - s.radius,
    y := s.position.y + s.radius,
    width := s.radius * 2,
    height := s.radius * 2,
  }]

def Shell.emit (shell: Shell): Types.Msg :=
  Types.Msg.Bounds (Types.ID.Shell shell.id) shell.bounds

def Shell.view (s: Shell): Draw.Draw :=
  Draw.Draw.Circle ⟨ s.position, s.radius ⟩ Colors.yellow

structure Shells where
  private maxWidth : Float
  private maxHeight : Float
  private oceanWidth : Float
  private oceanHeight : Float
  private nextID : Nat
  private shellsMap : Std.HashMap Nat Shell
  private timeUntilSpawn: Float
  private rand: Rand.Generator

def init (maxWidth: Nat) (maxHeight: Nat) (r: Rand.Generator): Shells :=
  {
    maxWidth := maxWidth.toFloat,
    maxHeight := maxHeight.toFloat,
    oceanWidth := 0,
    oceanHeight := maxHeight.toFloat,
    nextID := 0,
    shellsMap := Std.HashMap.empty,
    timeUntilSpawn := 1000,
    rand := r,
  }

def Shells.emit (shells: Shells): List Types.Msg :=
  (Std.HashMap.map (λ _ shell => shell.emit) shells.shellsMap).values

def Shells.delete (shells: Shells) (id: Nat): Shells :=
  let shellList := shells.shellsMap.toList
  let filteredList := List.filter (λ (shellID, _) => shellID != id) shellList
  { shells with
    shellsMap := Std.HashMap.ofList filteredList,
  }

def Shells.add (shells: Shells): Shells :=
  let (newNum1, newGen1) := shells.rand.next
  let (newNum2, newGen2) := newGen1.next
  let maxWidth := shells.oceanWidth.toUInt64.toNat
  let maxHeight := shells.oceanHeight.toUInt64.toNat
  let location: Shape.Vector2 := ⟨ (newNum1 % maxWidth).toFloat, (newNum2 % maxHeight).toFloat ⟩
  let x := (shells.maxWidth - shells.oceanWidth) + location.x
  let coords := ⟨x, location.y⟩
  let newShell := Shell.init shells.nextID coords
  let shellsMap := shells.shellsMap.insert shells.nextID newShell
  { shells with
    timeUntilSpawn := shells.timeUntilSpawn + 3,
    nextID := shells.nextID + 1,
    shellsMap := shellsMap,
    rand := newGen2,
  }

def Shells.decSpawnTime (shells: Shells) (delta: Float): Shells :=
  if shells.timeUntilSpawn < 0
  then shells.add
  else { shells with
    timeUntilSpawn := shells.timeUntilSpawn - delta,
  }

def Shells.resetSpawnTime (shells: Shells): Shells :=
  { shells with
    timeUntilSpawn := 1,
  }

def Shells.update (shells: Shells) (msg: Types.Msg): Id Shells := do
  match msg with
  | Types.Msg.Bounds Types.ID.Ocean boxes =>
    let mut oceanWidth := shells.oceanWidth
    for box in boxes do
      oceanWidth := box.width
    return { shells with
      oceanWidth := oceanWidth,
    }
  | Types.Msg.Collision (Types.ID.Shell id) Types.ID.Player =>
    shells.delete id
  | Types.Msg.OceanPullingBack _ =>
    shells.resetSpawnTime
  | Types.Msg.Time delta =>
    shells.decSpawnTime delta
  | _otherwise =>
    shells

def Shells.view (shells: Shells): List Draw.Draw :=
  List.map (·.view) shells.shellsMap.values

instance : Types.Model Shells where
  emit := Shells.emit
  update := Shells.update
  view := Shells.view

end Shells
