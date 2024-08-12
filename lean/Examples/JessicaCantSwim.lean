import «Raylib»

import Examples.JessicaCantSwim.Game
import Examples.JessicaCantSwim.Keys
import Examples.JessicaCantSwim.Entity

namespace JessicaCantSwim

def main : IO Unit := do
  let screenWidth: Nat := 800
  let screenHeight : Nat := 450
  let startPosition : Vector2 := { x := 200, y := 200 }
  initWindow screenWidth screenHeight "Jessica Can't Swim"
  setTargetFPS 60
  let mut game := Game.init startPosition screenWidth screenHeight
  while not (← windowShouldClose) do
    let delta ← getFrameTime
    let keys ← Keys.getKeys
    let events: List Entity.Event := List.map (λ key => Entity.Event.Key key) keys
    game := game.update delta events
    renderFrame do
      game.render
  closeWindow

end JessicaCantSwim
