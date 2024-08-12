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
  player: Player.Player
  ocean: Ocean.Ocean
  scoreboard: Scoreboard.Scoreboard

def init (position: Vector2) (screenWidth: Nat) (screenHeight: Nat): Game :=
  let camera := Camera.init position screenWidth screenHeight
  {
    camera := camera,
    -- Add your new Entity:
    player := Player.init position,
    scoreboard := Scoreboard.init,
    ocean := Ocean.init screenWidth screenHeight,
  }

def Game.entities (game: Game): Entity.Entities :=
  Entity.Entities.mk [
    -- Add your new Entity:
    Entity.wrap <| game.player,
    Entity.wrap <| game.scoreboard,
    Entity.wrap <| game.ocean,
  ]

private def Game.update (game: Game) (delta : Float) (events: List Entity.Event): Game :=
  {
    camera := game.camera,
    -- Add your new Entity:
    player := game.player.update delta events
    scoreboard := game.scoreboard.update delta events
    ocean := game.ocean.update delta events
  }

def Game.step (game: Game) (delta : Float) (externalEvents: List Entity.Event): Game :=
  let collisions := Collision.detectEvents game.entities
  let allEvents := List.append externalEvents collisions
  Game.update game delta allEvents

def Game.render (game: Game): IO Unit := do
  clearBackground Color.Raylib.lightgray
  renderWithCamera2D game.camera.camera do
    game.entities.render
  return ()

end Game
