import «Raylib»

import Examples.JessicaCantSwim.Game

namespace JessicaCantSwim

open Examples.JessicaCantSwim.Game

private def screenWidth : Nat := 800
private def screenHeight : Nat := 450
private def startPosition : Vector2 := { x := 200, y := 200}
private def fps : Nat := 60

private def doRender : GameM Unit := do
  while not (← windowShouldClose) do
    Game.update (← getFrameTime)
    renderFrame do
      Game.render
  closeWindow

def main : IO Unit := do
  let initGame := Game.init startPosition screenWidth screenHeight
  initWindow screenWidth screenHeight "Jessica Can't Swim"
  setTargetFPS fps
  doRender |>.run' initGame

end JessicaCantSwim
