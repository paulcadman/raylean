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

private def Ocean.id (_entity: Ocean): Entity.ID :=
  Entity.ID.Ocean

private def Ocean.box (ocean: Ocean): Rectangle :=
  {
    x := ocean.maxWidth - ocean.width,
    y := 0,
    width := ocean.width,
    height := ocean.height,
  }

def Ocean.emit (entity: Ocean): List Entity.Msg :=
  let boundsMsg := Entity.Msg.Bounds entity.id [entity.box]
  let pullingBackMsg := Entity.Msg.OceanPullingBack entity.width
  let requestRandMsg := Entity.Msg.RequestRand entity.id 100
  if entity.speed < 0 && !entity.pulledback
    then [ boundsMsg, pullingBackMsg]
  else if entity.resetting
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

def Ocean.update (ocean: Ocean) (msg: Entity.Msg): Ocean :=
  match msg with
  | Entity.Msg.ResponseRand Entity.ID.Ocean r =>
    if ocean.resetting
    then ocean.reset r.toFloat
    else ocean
  | Entity.Msg.OceanPullingBack _ => ocean.alreadyPulledBack
  | Entity.Msg.Time delta => ocean.move delta
  | _otherwise => ocean

def Ocean.render (ocean: Ocean): IO Unit := do
  let rect: Rectangle := ocean.box
  drawRectangleRec rect Color.blue

instance : Entity.Entity Ocean where
  emit := Ocean.emit
  update := Ocean.update
  render := Ocean.render

end Ocean
