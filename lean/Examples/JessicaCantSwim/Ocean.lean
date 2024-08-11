import «Raylib»
import Raylib.Types

namespace Examples.JessicaCantSwim.Ocean

structure Ocean where
  private maxWidth: Float
  private height: Float
  private gravity: Float
  private width: Float
  private speed: Float

def Ocean.init (maxWidth: Nat) (height: Nat) : Ocean :=
  {
    width := 0,
    maxWidth := maxWidth.toFloat,
    height := height.toFloat,
    speed := 100,
    gravity := 9.8,
  }

def Ocean.update (ocean: Ocean) (delta : Float) : Id Ocean := do
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

def Ocean.render (ocean: Ocean): IO Unit := do
  let rect: Rectangle := {
    x := ocean.maxWidth - ocean.width,
    y := 0,
    width := ocean.width,
    height := ocean.height,
  }
  drawRectangleRec rect Color.blue
