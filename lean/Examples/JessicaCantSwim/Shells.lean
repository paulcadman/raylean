import Std

import «Raylib»

import Examples.JessicaCantSwim.Types
import Examples.JessicaCantSwim.Draw

namespace Shells

structure Shell where
  private id: Nat
  private position : Vector2
  private radius: Float

def Shell.init (id: Nat) (position: Vector2): Shell :=
  {
    id := id,
    position := position,
    radius := 5,
  }

def Shell.bounds (s: Shell): List Rectangle :=
  [{
    x := s.position.x - s.radius,
    y := s.position.y + s.radius,
    width := s.radius * 2,
    height := s.radius * 2,
  }]

def Shell.emit (shell: Shell): Types.Msg :=
  Types.Msg.Bounds (Types.ID.Shell shell.id) shell.bounds

def Shell.view (s: Shell): Draw.Draw :=
  Draw.Draw.Circle s.position s.radius Color.yellow

structure Shells where
  private maxWidth : Float
  private maxHeight : Float
  private oceanWidth : Float
  private oceanHeight : Float
  private nextID : Nat
  private shellsMap : Std.HashMap Nat Shell
  private timeUntilSpawn: Float

def init (maxWidth: Nat) (maxHeight: Nat): Shells :=
  {
    maxWidth := maxWidth.toFloat,
    maxHeight := maxHeight.toFloat,
    oceanWidth := 0,
    oceanHeight := maxHeight.toFloat,
    nextID := 0,
    shellsMap := Std.HashMap.empty,
    timeUntilSpawn := 1000,
  }

def Shells.emit (shells: Shells): Id (List Types.Msg) := do
  let bounds := (Std.HashMap.map (λ _ shell => shell.emit) shells.shellsMap).values
  if shells.timeUntilSpawn > 0 then
    return bounds
  let maxWidth := shells.oceanWidth.toUInt64.toNat
  let maxHeight := shells.oceanHeight.toUInt64.toNat
  bounds.concat (Types.Msg.RequestRandPair Types.ID.Shells (maxWidth, maxHeight) )

def Shells.delete (shells: Shells) (id: Nat): Shells :=
  let shellList := shells.shellsMap.toList
  let filteredList := List.filter (λ (shellID, _) => shellID != id) shellList
  { shells with
    shellsMap := Std.HashMap.ofList filteredList,
  }

def Shells.add (shells: Shells) (location: Vector2): Shells :=
  let x := (shells.maxWidth - shells.oceanWidth) + location.x
  let coords := ⟨x, location.y⟩
  let newShell := Shell.init shells.nextID coords
  let shellsMap := shells.shellsMap.insert shells.nextID newShell
  { shells with
    timeUntilSpawn := shells.timeUntilSpawn + 3,
    nextID := shells.nextID + 1,
    shellsMap := shellsMap,
  }

def Shells.decSpawnTime (shells: Shells) (delta: Float): Shells :=
  { shells with
    timeUntilSpawn := shells.timeUntilSpawn - delta,
  }

def Shells.resetSpawnTime (shells: Shells): Shells :=
  { shells with
    timeUntilSpawn := 1,
  }

def Shells.update (shells: Shells) (msg: Types.Msg): Id Shells := do
  match msg with
  | Types.Msg.ResponseRandPair Types.ID.Shells (rx, ry) =>
    shells.add ⟨ rx.toFloat, ry.toFloat ⟩
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
