import «Raylib»

import Examples.JessicaCantSwim.GameState
import Examples.JessicaCantSwim.Player

namespace JessicaCantSwim

open Examples.JessicaCantSwim.GameState
open Examples.JessicaCantSwim.Player

private def screenWidth : Nat := 800
private def screenHeight : Nat := 450
private def fps : Nat := 60

private def doRender : GameM Unit := do
  while not (← windowShouldClose) do
    update (← getFrameTime)
    renderFrame do
      clearBackground Color.Raylib.lightgray
      renderWithCamera2D (← get).camera do
        render
  closeWindow

def initPlayer : Player :=
  {
    position := {x := 400, y := 200}
  }

def initCamera : Camera2D := {
  target := initPlayer.position,
  offset := { x := screenWidth.toFloat / 2, y := screenHeight.toFloat / 2 }
  rotation := 0,
  zoom := 1
}

def initGameState : GameState :=
  {
    player := initPlayer,
    camera := initCamera,
  }

def main : IO Unit := do
  initWindow screenWidth screenHeight "Jessica Can't Swim"
  setTargetFPS fps
  doRender
  |>.run' initGameState

end JessicaCantSwim
