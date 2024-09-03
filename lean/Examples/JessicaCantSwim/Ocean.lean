import Examples.JessicaCantSwim.Types
import Examples.JessicaCantSwim.Rand

namespace Ocean

structure Ocean where
  private maxWidth: Float
  private height: Float
  private gravity: Float
  private width: Float
  private speed: Float
  private pulledback: Bool
  private rand: Rand.Generator

def init (maxWidth: Nat) (height: Nat) (r: Rand.Generator) : Ocean :=
  {
    width := 0,
    maxWidth := maxWidth.toFloat,
    height := height.toFloat,
    speed := 100,
    gravity := 9.8,
    pulledback := false
    rand := r
  }

private def Ocean.id (_ocean: Ocean): Types.ID :=
  Types.ID.Ocean

private def Ocean.box (ocean: Ocean): Shape.Rectangle :=
  {
    x := ocean.maxWidth - ocean.width,
    y := 0,
    width := ocean.width,
    height := ocean.height,
  }

def Ocean.emit (ocean: Ocean): List Types.Msg :=
  let boundsMsg := Types.Msg.Bounds ocean.id [ocean.box]
  let pullingBackMsg := Types.Msg.OceanPullingBack ocean.width
  if ocean.speed < 0 && !ocean.pulledback
    then [ boundsMsg, pullingBackMsg]
  else [ boundsMsg ]

-- Once the ocean is pulled back, reset it to a new speed
private def Ocean.reset (ocean: Ocean): Ocean :=
  let (newNum, newGen) := ocean.rand.next
  let newSpeed := (newNum % 100).toFloat
  { ocean with
    width := 0,
    speed := newSpeed,
    pulledback := false,
    rand := newGen,
  }

-- Avoids sending Msg.OceanPullingBack twice
private def Ocean.alreadyPulledBack (ocean: Ocean): Ocean :=
  { ocean with pulledback := true }

private def Ocean.move (ocean: Ocean) (delta: Float): Ocean :=
  if ocean.width < 0
  then ocean.reset
  else
    let width := ocean.width + ocean.speed * delta
    let speed := ocean.speed - ocean.gravity * delta
    { ocean with
      width := width,
      speed := speed,
    }

def Ocean.update (ocean: Ocean) (msg: Types.Msg): Ocean :=
  match msg with
  | Types.Msg.OceanPullingBack _ => ocean.alreadyPulledBack
  | Types.Msg.Time delta => ocean.move delta
  | _otherwise => ocean

def Ocean.view (ocean: Ocean): List Draw.Draw :=
  [Draw.Draw.Rectangle ocean.box Colors.blue]

instance : Types.Model Ocean where
  emit := Ocean.emit
  update := Ocean.update
  view := Ocean.view

end Ocean
