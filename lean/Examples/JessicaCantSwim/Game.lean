import Raylib.Types

import Examples.JessicaCantSwim.Camera
import Examples.JessicaCantSwim.Collision
import Examples.JessicaCantSwim.Keys
import Examples.JessicaCantSwim.Entity
import Examples.JessicaCantSwim.Player
import Examples.JessicaCantSwim.Scoreboard
import Examples.JessicaCantSwim.Ocean

namespace Game

structure Game where
  camera : Camera.Camera
  -- Add your new Entity here:
  player: Player.Player
  ocean: Ocean.Ocean
  scoreboard: Scoreboard.Scoreboard

def init (position: Vector2) (screenWidth: Nat) (screenHeight: Nat): Game :=
  let camera := Camera.init position screenWidth screenHeight
  {
    camera := camera,
    -- Add your new Entity here:
    player := Player.init position,
    scoreboard := Scoreboard.init,
    ocean := Ocean.init screenWidth screenHeight,
  }

private def Game.update (game: Game) (delta : Float) (events: List Entity.Event): Game :=
  {
    camera := game.camera,
    -- Add your new Entity here:
    player := game.player.update delta events
    scoreboard := game.scoreboard.update delta events
    ocean := game.ocean.update delta events
  }

def Game.render (game: Game): IO Unit := do
  clearBackground Color.Raylib.lightgray
  renderWithCamera2D game.camera.camera do
    -- Add your new Entity here:
    game.ocean.render
    game.player.render
    game.scoreboard.render
  return ()

def Game.step (game: Game) (delta : Float) (externalEvents: List Entity.Event): Game :=
  let collisions := Collision.detectEvents <| Entity.Entities.mk [
    -- Add your new Entity here:
    Entity.wrap <| game.ocean,
    Entity.wrap <| game.player
  ]
  let allEvents := List.append externalEvents collisions
  Game.update game delta allEvents

end Game
