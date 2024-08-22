import «Raylib»
import Raylib.Types

import Examples.JessicaCantSwim.Types

namespace Ocean

structure Ocean where
  private maxWidth: Float
  private height: Float
  private gravity: Float
  private width: Float
  private speed: Float
  private resetting: Bool
  private pulledback: Bool

def init (maxWidth: Nat) (height: Nat) : Ocean :=
  {
    width := 0,
    maxWidth := maxWidth.toFloat,
    height := height.toFloat,
    speed := 100,
    gravity := 9.8,
    resetting := false
    pulledback := false
  }

private def Ocean.id (_ocean: Ocean): Types.ID :=
  Types.ID.Ocean

private def Ocean.box (ocean: Ocean): Rectangle :=
  {
    x := ocean.maxWidth - ocean.width,
    y := 0,
    width := ocean.width,
    height := ocean.height,
  }

def Ocean.emit (ocean: Ocean): List Types.Msg :=
  let boundsMsg := Types.Msg.Bounds ocean.id [ocean.box]
  let pullingBackMsg := Types.Msg.OceanPullingBack ocean.width
  let requestRandMsg := Types.Msg.RequestRand ocean.id 100
  if ocean.speed < 0 && !ocean.pulledback
    then [ boundsMsg, pullingBackMsg]
  else if ocean.resetting
    then [ requestRandMsg ]
  else [ boundsMsg ]

-- Once the ocean is pulled back, reset it to a new speed
private def Ocean.reset (ocean: Ocean) (speed: Float): Ocean :=
  { ocean with
    resetting := false,
    width := 0,
    speed := speed,
    pulledback := false,
  }

-- Avoids sending Msg.OceanPullingBack twice
private def Ocean.alreadyPulledBack (ocean: Ocean): Ocean :=
  { ocean with pulledback := true }

private def Ocean.move (ocean: Ocean) (delta: Float): Ocean :=
  let width := ocean.width + ocean.speed * delta
  let speed := ocean.speed - ocean.gravity * delta
  { ocean with
    resetting := width < 0
    width := width,
    speed := speed,
  }

def Ocean.update (ocean: Ocean) (msg: Types.Msg): Ocean :=
  match msg with
  | Types.Msg.ResponseRand Types.ID.Ocean r =>
    if ocean.resetting
    then ocean.reset r.toFloat
    else ocean
  | Types.Msg.OceanPullingBack _ => ocean.alreadyPulledBack
  | Types.Msg.Time delta => ocean.move delta
  | _otherwise => ocean

def Ocean.render (ocean: Ocean): IO Unit := do
  let rect: Rectangle := ocean.box
  drawRectangleRec rect Color.blue

instance : Types.Model Ocean where
  emit := Ocean.emit
  update := Ocean.update
  render := Ocean.render

end Ocean
