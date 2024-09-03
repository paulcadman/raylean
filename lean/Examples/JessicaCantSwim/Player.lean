import «Raylib»

import Examples.JessicaCantSwim.Keys
import Examples.JessicaCantSwim.Shape
import Examples.JessicaCantSwim.Types

namespace Player

structure Player where
  private position : Shape.Vector2
  private speed: Float
  private radius : Float
  private direction : Vector2

def init (position: Shape.Vector2): Player :=
  {
    position := position,
    speed := 200,
    radius := 10,
    direction := ⟨0, 0⟩,
  }

private def Player.id (_player: Player): Types.ID :=
  Types.ID.Player

def Player.bounds (p: Player): List Shape.Rectangle :=
  [{
    x := p.position.x - p.radius,
    y := p.position.y + p.radius,
    width := p.radius * 2,
    height := p.radius * 2,
  }]

def Player.emit (player: Player): List Types.Msg := [
    Types.Msg.Bounds player.id player.bounds
  ]

private def Player.left (p: Player): Player :=
  { p with direction := ⟨ -1, p.direction.y ⟩ }

private def Player.right (p: Player): Player :=
  { p with direction := ⟨ 1, p.direction.y ⟩ }

private def Player.up (p: Player): Player :=
  { p with direction := ⟨ p.direction.x, -1 ⟩ }

private def Player.down (p: Player): Player :=
  { p with direction := ⟨ p.direction.x, 1 ⟩ }

private def Player.move (p: Player) (delta: Float): Player :=
  let factor := p.speed * delta
  let newPosition := ⟨ p.position.x + factor * p.direction.x , p.position.y + factor * p.direction.y ⟩
  { p with
    direction := ⟨0, 0⟩,
    position := newPosition,
  }

def Player.update (p: Player) (msg: Types.Msg): Player :=
  match msg with
  | Types.Msg.Key Keys.Keys.Left => p.left
  | Types.Msg.Key Keys.Keys.Right => p.right
  | Types.Msg.Key Keys.Keys.Up => p.up
  | Types.Msg.Key Keys.Keys.Down => p.down
  | Types.Msg.Time delta => p.move delta
  | _otherwise => p

-- IO is required, since we are drawing
def Player.view (p: Player): List Draw.Draw :=
  [Draw.Draw.Circle p.position p.radius Color.green]

instance : Types.Model Player where
  emit := Player.emit
  update := Player.update
  view := Player.view

end Player
