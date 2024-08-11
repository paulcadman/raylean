import «Raylib»

import Examples.JessicaCantSwim.Keys
open Examples.JessicaCantSwim.Keys

namespace Examples.JessicaCantSwim.Player

structure Player where
  private position : Vector2
  private speed: Float
  private radius : Float

def Player.init (position: Vector2): Player :=
  {
    position := position,
    speed := 200,
    radius := 10,
  }

private def Player.modifyPositionX (p: Player) (f : Float → Float) : Player :=
  { p with position := ⟨ f p.position.x, p.position.y ⟩}

private def Player.modifyPositionY (p: Player) (f : Float → Float) : Player :=
  { p with position := ⟨ p.position.x, f p.position.y ⟩}

def Player.update (p: Player) (delta : Float) (keys: List Keys.Keys): Id Player := do
  let mut p := p
  let move := p.speed * delta
  if (keys.contains Keys.Left) then p := p.modifyPositionX (· - move)
  if (keys.contains Keys.Right) then p := p.modifyPositionX (· + move)
  if (keys.contains Keys.Up) then p := p.modifyPositionY (· - move)
  if (keys.contains Keys.Down) then p := p.modifyPositionY (· + move)
  return p

def Player.bounds (p: Player): Rectangle :=
  {
    x := p.position.x - p.radius,
    y := p.position.y + p.radius,
    width := p.radius * 2,
    height := p.radius * 2,
  }

-- IO is required, since we are drawing
def Player.render (p: Player): IO Unit := do
  drawCircleV p.position p.radius Color.green

end Examples.JessicaCantSwim.Player
