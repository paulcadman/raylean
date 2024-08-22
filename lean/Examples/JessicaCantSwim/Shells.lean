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
  private shells : Std.HashMap Nat Shell
  private timeUntilSpawn: Float

def init (maxWidth: Nat) (maxHeight: Nat): Shells :=
  {
    maxWidth := maxWidth.toFloat,
    maxHeight := maxHeight.toFloat,
    oceanWidth := 0,
    oceanHeight := maxHeight.toFloat,
    nextID := 0,
    shells := Std.HashMap.empty,
    timeUntilSpawn := 1000,
  }

def Shells.emit (entity: Shells): Id (List Entity.Msg) := do
  let bounds := (Std.HashMap.map (λ _ shell => shell.emit) entity.shells).values
  if entity.timeUntilSpawn > 0 then
    return bounds
  let maxWidth := entity.oceanWidth.toUInt64.toNat
  let maxHeight := entity.oceanHeight.toUInt64.toNat
  bounds.concat (Entity.Msg.RequestRandPair Entity.ID.Shells (maxWidth, maxHeight) )

def Shells.delete (shells: Shells) (id: Nat): Shells :=
  let shellList := shells.shells.toList
  let filteredList := List.filter (λ (shellID, _) => shellID != id) shellList
  { shells with
    shells := Std.HashMap.ofList filteredList,
  }

def Shells.update (entity: Shells) (msg: Entity.Msg): Id Shells := do
  match msg with
  | Entity.Msg.ResponseRandPair Entity.ID.Shells (rx, ry) =>
    let x := (entity.maxWidth - entity.oceanWidth) + rx.toFloat
    let coords := ⟨x, ry.toFloat⟩
    let newShell := Shell.init entity.nextID coords
    let shells := entity.shells.insert entity.nextID newShell
    return { entity with
      timeUntilSpawn := entity.timeUntilSpawn + 3,
      nextID := entity.nextID + 1,
      shells := shells,
    }
  | Entity.Msg.Bounds Entity.ID.Ocean boxes =>
    let mut oceanWidth := entity.oceanWidth
    for box in boxes do
      oceanWidth := box.width
    return { entity with
      oceanWidth := oceanWidth,
    }
  | Entity.Msg.Collision (Entity.ID.Shell id) Entity.ID.Player =>
    entity.delete id
  | Entity.Msg.OceanPullingBack _ =>
    return { entity with
      timeUntilSpawn := 1,
    }
  | Entity.Msg.Time delta =>
    return { entity with
      timeUntilSpawn := entity.timeUntilSpawn - delta,
    }
  | _otherwise =>
    entity

def Shells.render (entity: Shells): IO Unit := do
  for (_, shell) in entity.shells do
    shell.render

instance : Entity.Entity Shells where
  emit := Shells.emit
  update := Shells.update
  render := Shells.render

end Shells
