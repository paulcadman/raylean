import «Raylib»

import Examples.JessicaCantSwim.Game
import Examples.JessicaCantSwim.Keys

namespace JessicaCantSwim

open Examples.JessicaCantSwim.Game
open Examples.JessicaCantSwim.Keys

def main : IO Unit := do
  let screenWidth: Nat := 800
  let screenHeight : Nat := 450
  let startPosition : Vector2 := { x := 200, y := 200 }
  initWindow screenWidth screenHeight "Jessica Can't Swim"
  setTargetFPS 60
  let mut game := Game.init startPosition screenWidth screenHeight
  while not (← windowShouldClose) do
    let delta ← getFrameTime
    let keys ← getKeys
    game := game.update delta keys
    renderFrame do
      game.render
  closeWindow

end JessicaCantSwim
