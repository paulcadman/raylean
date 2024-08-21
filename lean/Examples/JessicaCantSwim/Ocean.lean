import «Raylib»
import Raylib.Types

import Examples.JessicaCantSwim.Entity

namespace Ocean

structure Ocean where
  private maxWidth: Float
  private height: Float
  private gravity: Float
  private width: Float
  private speed: Float
  private resetting: Bool

def init (maxWidth: Nat) (height: Nat) : Ocean :=
  {
    width := 0,
    maxWidth := maxWidth.toFloat,
    height := height.toFloat,
    speed := 100,
    gravity := 9.8,
    resetting := false
  }

def Ocean.id (_entity: Ocean): Entity.ID :=
  Entity.ID.Ocean

private def Ocean.box (ocean: Ocean): Rectangle :=
  {
    x := ocean.maxWidth - ocean.width,
    y := 0,
    width := ocean.width,
    height := ocean.height,
  }

def Ocean.bounds (ocean: Ocean): List Rectangle :=
  [ocean.box]

def Ocean.emit (entity: Ocean): List Entity.Msg :=
  if entity.resetting
  then [ Entity.Msg.RequestRand entity.id ]
  else [ Entity.Msg.Bounds entity.id entity.bounds ]

def Ocean.update (ocean: Ocean) (delta : Float) (msg: Entity.Msg): Id Ocean := do
  match msg with
  | Entity.Msg.Rand id r =>
    if (id == ocean.id && ocean.resetting)
    then return {
      resetting := false,
      maxWidth := ocean.maxWidth,
      height := ocean.height,
      gravity := ocean.gravity,
      width := 0,
      speed := r.toFloat,
    }
    else ocean
  | _otherwise =>
    let move := ocean.speed * delta
    let width := ocean.width + move
    let speed := ocean.speed - ocean.gravity * delta
    {
      resetting := width < 0
      maxWidth := ocean.maxWidth,
      height := ocean.height,
      gravity := ocean.gravity,
      width := width,
      speed := speed,
    }

def Ocean.render (ocean: Ocean): IO Unit := do
  let rect: Rectangle := ocean.box
  drawRectangleRec rect Color.blue

instance : Entity.Entity Ocean where
  id := Ocean.id
  emit := Ocean.emit
  update := Ocean.update
  bounds := Ocean.bounds
  render := Ocean.render

end Ocean
