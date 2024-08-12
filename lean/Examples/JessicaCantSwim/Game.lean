import Raylib.Types

import Examples.JessicaCantSwim.Camera
import Examples.JessicaCantSwim.Collision
import Examples.JessicaCantSwim.Keys
import Examples.JessicaCantSwim.Player
import Examples.JessicaCantSwim.Ocean

namespace Game

structure Game where
  camera : Camera.Camera
  player : Player.Player
  ocean : Ocean.Ocean

def init (position: Vector2) (screenWidth: Nat) (screenHeight: Nat): Game :=
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

def Game.detectCollision (game: Game): Bool :=
  Collision.detect game.player.bounds game.ocean.bounds

def Game.render (game: Game): IO Unit := do
  clearBackground Color.Raylib.lightgray
  renderWithCamera2D game.camera.camera do
    if game.detectCollision then drawText "Game Over" 10 10 24 Color.black
    game.player.render
    game.ocean.render
  return ()

end Game
