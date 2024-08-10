import «Raylib»

import Examples.JessicaCantSwim.Types

namespace JessicaCantSwim

open JessicaCantSwim.Types

private def screenWidth : Nat := 800
private def screenHeight : Nat := 450
private def player_speed : Float := 200
private def player_radius : Float := 10
private def fps : Nat := 60

def updatePlayer (delta : Float) : GameM Unit := do
  if (← isKeyDown Key.left) then modifyPositionX (· - player_speed * delta)
  if (← isKeyDown Key.right) then modifyPositionX (· + player_speed * delta)
  if (← isKeyDown Key.up) then modifyPositionY (· - player_speed * delta)
  if (← isKeyDown Key.down) then modifyPositionY (· + player_speed * delta)

private def renderPlayer : GameM Unit := do
  let p := (← get).player
  drawCircleV p.position player_radius Color.green

private def doRender : GameM Unit := do
  while not (← windowShouldClose) do
    updatePlayer (← getFrameTime)
    renderFrame do
      clearBackground Color.Raylib.lightgray
      renderWithCamera2D (← get).camera do
        renderPlayer
  closeWindow

def initPlayer : Player := { position := {x := 400, y := 200} }

def initCamera : Camera2D := {
  target := initPlayer.position,
  offset := { x := screenWidth.toFloat / 2, y := screenHeight.toFloat / 2 }
  rotation := 0,
  zoom := 1
}

def initGameState : GameState := { player := initPlayer, camera := initCamera }

def main : IO Unit := do
  initWindow screenWidth screenHeight "Jessica Can't Swim"
  setTargetFPS fps
  doRender
  |>.run' initGameState

end JessicaCantSwim
