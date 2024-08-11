import Examples.JessicaCantSwim.Keys
open Examples.JessicaCantSwim.Keys

namespace Examples.JessicaCantSwim.Player

private def speed : Float := 200
private def radius : Float := 10

structure Player where
  position : Vector2

private def Player.modifyPositionX (p: Player) (f : Float → Float) : Player :=
  { p with position := ⟨ f p.position.x, p.position.y ⟩}

private def Player.modifyPositionY (p: Player) (f : Float → Float) : Player :=
  { p with position := ⟨ p.position.x, f p.position.y ⟩}

def Player.update (p: Player) (delta : Float) (keys: List Keys.Keys): Id Player := do
  let mut p := p
  let move := speed * delta
  if (keys.contains Keys.Left) then p := p.modifyPositionX (· - move)
  if (keys.contains Keys.Right) then p := p.modifyPositionX (· + move)
  if (keys.contains Keys.Up) then p := p.modifyPositionY (· - move)
  if (keys.contains Keys.Down) then p := p.modifyPositionY (· + move)
  return p

-- IO is required, since we are drawing
def Player.render (p: Player): IO Unit := do
  drawCircleV p.position radius Color.green

end Examples.JessicaCantSwim.Player
