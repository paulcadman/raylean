import Raylib.Types

import Examples.JessicaCantSwim.Player
import Examples.JessicaCantSwim.Keys
import Examples.JessicaCantSwim.Camera

open Examples.JessicaCantSwim.Player
open Examples.JessicaCantSwim.Keys
open Examples.JessicaCantSwim.Camera

namespace Examples.JessicaCantSwim.Game

structure Game where
  player : Player
  camera : Camera

def Game.init (position: Vector2) (screenWidth: Nat) (screenHeight: Nat): Game :=
  {
    player := Player.init position,
    camera := Camera.init position screenWidth screenHeight,
  }

def Game.update (game: Game) (delta : Float) (keys: List Keys.Keys): Game :=
  {
    player := game.player.update delta keys,
    camera := game.camera,
  }

def Game.render (game: Game): IO Unit := do
  let player: Player := game.player
  clearBackground Color.Raylib.lightgray
  renderWithCamera2D game.camera.camera do
    player.render
  return ()

end Examples.JessicaCantSwim.Game
