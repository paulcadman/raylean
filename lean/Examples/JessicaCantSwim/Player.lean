import «Raylib»

import Examples.JessicaCantSwim.Keys
import Examples.JessicaCantSwim.Entity

namespace Player

structure Player where
  private position : Vector2
  private speed: Float
  private radius : Float
  private direction : Vector2

def init (position: Vector2): Player :=
  {
    position := position,
    speed := 200,
    radius := 10,
    direction := ⟨0, 0⟩,
  }

private def Player.id (_entity: Player): Entity.ID :=
  Entity.ID.Player

def Player.bounds (p: Player): List Rectangle :=
  [{
    x := p.position.x - p.radius,
    y := p.position.y + p.radius,
    width := p.radius * 2,
    height := p.radius * 2,
  }]

def Player.emit (entity: Player): List Entity.Msg := [
    Entity.Msg.Bounds entity.id entity.bounds
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

def Player.update (p: Player) (msg: Entity.Msg): Player :=
  match msg with
  | Entity.Msg.Key Keys.Keys.Left => p.left
  | Entity.Msg.Key Keys.Keys.Right => p.right
  | Entity.Msg.Key Keys.Keys.Up => p.up
  | Entity.Msg.Key Keys.Keys.Down => p.down
  | Entity.Msg.Time delta => p.move delta
  | _otherwise => p

-- IO is required, since we are drawing
def Player.render (p: Player): IO Unit := do
  drawCircleV p.position p.radius Color.green

instance : Entity.Entity Player where
  emit := Player.emit
  update := Player.update
  render := Player.render

end Player
