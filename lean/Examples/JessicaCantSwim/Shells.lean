import Std

import «Raylib»

import Examples.JessicaCantSwim.Entity

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

def Shell.emit (entity: Shell): Entity.Msg :=
  Entity.Msg.Bounds (Entity.ID.Shell entity.id) entity.bounds

def Shell.render (s: Shell): IO Unit := do
  drawCircleV s.position s.radius Color.yellow

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

def Shells.emit (entity: Shells): Id (List Entity.Msg) := do
  let bounds := (Std.HashMap.map (λ _ shell => shell.emit) entity.shellsMap).values
  if entity.timeUntilSpawn > 0 then
    return bounds
  let maxWidth := entity.oceanWidth.toUInt64.toNat
  let maxHeight := entity.oceanHeight.toUInt64.toNat
  bounds.concat (Entity.Msg.RequestRandPair Entity.ID.Shells (maxWidth, maxHeight) )

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

def Shells.update (shells: Shells) (msg: Entity.Msg): Id Shells := do
  match msg with
  | Entity.Msg.ResponseRandPair Entity.ID.Shells (rx, ry) =>
    shells.add ⟨ rx.toFloat, ry.toFloat ⟩
  | Entity.Msg.Bounds Entity.ID.Ocean boxes =>
    let mut oceanWidth := shells.oceanWidth
    for box in boxes do
      oceanWidth := box.width
    return { shells with
      oceanWidth := oceanWidth,
    }
  | Entity.Msg.Collision (Entity.ID.Shell id) Entity.ID.Player =>
    shells.delete id
  | Entity.Msg.OceanPullingBack _ =>
    shells.resetSpawnTime
  | Entity.Msg.Time delta =>
    shells.decSpawnTime delta
  | _otherwise =>
    shells

def Shells.render (entity: Shells): IO Unit := do
  for (_, shell) in entity.shellsMap do
    shell.render

instance : Entity.Entity Shells where
  emit := Shells.emit
  update := Shells.update
  render := Shells.render

end Shells
