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

def init (maxWidth: Nat) (height: Nat) : Ocean :=
  {
    width := 0,
    maxWidth := maxWidth.toFloat,
    height := height.toFloat,
    speed := 100,
    gravity := 9.8,
  }

def Ocean.id (_entity: Ocean): Entity.ID :=
  Entity.ID.Ocean

def Ocean.update (ocean: Ocean) (delta : Float) (_event: Entity.Event): Id Ocean := do
  let move := ocean.speed * delta
  let mut width := ocean.width + move
  let mut speed := ocean.speed - ocean.gravity * delta
  if width < 0 then
    speed := 100
  {
    maxWidth := ocean.maxWidth,
    height := ocean.height,
    gravity := ocean.gravity,
    width := width,
    speed := speed,
  }

private def Ocean.box (ocean: Ocean): Rectangle :=
  {
    x := ocean.maxWidth - ocean.width,
    y := 0,
    width := ocean.width,
    height := ocean.height,
  }

def Ocean.bounds (ocean: Ocean): List Rectangle :=
  [ocean.box]

def Ocean.render (ocean: Ocean): IO Unit := do
  let rect: Rectangle := ocean.box
  drawRectangleRec rect Color.blue

instance : Entity.Entity Ocean where
  id := Ocean.id
  update := Ocean.update
  bounds := Ocean.bounds
  render := Ocean.render

end Ocean
