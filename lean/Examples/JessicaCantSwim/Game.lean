import Raylib.Types

import Examples.JessicaCantSwim.Camera
import Examples.JessicaCantSwim.Keys
import Examples.JessicaCantSwim.Player
import Examples.JessicaCantSwim.Ocean

open Examples.JessicaCantSwim.Camera
open Examples.JessicaCantSwim.Keys
open Examples.JessicaCantSwim.Player
open Examples.JessicaCantSwim.Ocean

namespace Examples.JessicaCantSwim.Game

structure Game where
  camera : Camera
  player : Player
  ocean : Ocean

def Game.init (position: Vector2) (screenWidth: Nat) (screenHeight: Nat): Game :=
  {
    player := Player.init position,
    camera := Camera.init position screenWidth screenHeight,
    ocean := Ocean.init screenWidth screenHeight,
  }

def Game.update (game: Game) (delta : Float) (keys: List Keys.Keys): Game :=
  {
    camera := game.camera,
    player := game.player.update delta keys,
    ocean := game.ocean.update delta,
  }

def Game.render (game: Game): IO Unit := do
  clearBackground Color.Raylib.lightgray
  renderWithCamera2D game.camera.camera do
    game.player.render
    game.ocean.render
  return ()

end Examples.JessicaCantSwim.Game
