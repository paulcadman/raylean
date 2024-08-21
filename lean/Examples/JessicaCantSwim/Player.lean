import «Raylib»

import Examples.JessicaCantSwim.Keys
import Examples.JessicaCantSwim.Entity

namespace Player

structure Player where
  private position : Vector2
  private speed: Float
  private radius : Float

def init (position: Vector2): Player :=
  {
    position := position,
    speed := 200,
    radius := 10,
  }

def Player.id (_entity: Player): Entity.ID :=
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

private def Player.modifyPositionX (p: Player) (f : Float → Float) : Player :=
  { p with position := ⟨ f p.position.x, p.position.y ⟩}

private def Player.modifyPositionY (p: Player) (f : Float → Float) : Player :=
  { p with position := ⟨ p.position.x, f p.position.y ⟩}

def Player.update (p: Player) (delta: Float) (msg: Entity.Msg): Player :=
  let move := p.speed * delta
  match msg with
  | Entity.Msg.Key Keys.Keys.Left =>
    p.modifyPositionX (· - move)
  | Entity.Msg.Key Keys.Keys.Right =>
    p.modifyPositionX (· + move)
  | Entity.Msg.Key Keys.Keys.Up =>
    p.modifyPositionY (· - move)
  | Entity.Msg.Key Keys.Keys.Down =>
    p.modifyPositionY (· + move)
  | _otherwise =>
    p

-- IO is required, since we are drawing
def Player.render (p: Player): IO Unit := do
  drawCircleV p.position p.radius Color.green

instance : Entity.Entity Player where
  id := Player.id
  emit := Player.emit
  update := Player.update
  bounds := Player.bounds
  render := Player.render

end Player
