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
  player: Entity.Elem
  ocean: Entity.Elem
  scoreboard: Entity.Elem

def init (position: Vector2) (screenWidth: Nat) (screenHeight: Nat): Game :=
  let camera := Camera.init position screenWidth screenHeight

  let player := Entity.wrap <| Player.init position
  let scoreboard := Entity.wrap <| Scoreboard.init
  let ocean := Entity.wrap <| Ocean.init screenWidth screenHeight

  {
    camera := camera,
    player := player,
    scoreboard := scoreboard,
    ocean := ocean,
  }

def Game.entities (game: Game): Entity.Entities :=
  Entity.Entities.mk [
    game.player,
    game.scoreboard,
    game.ocean,
  ]

def Game.detectCollisions (game: Game): List Entity.Event :=
  let idBoundPairs : List (Entity.ID × List Rectangle) := game.entities.idBoundPairs
  let collisions := Collision.detects idBoundPairs
  List.map (λ collision => Entity.Event.Collision collision.1 collision.2) collisions

def Game.update (game: Game) (delta : Float) (externalEvents: List Entity.Event): Game :=
  let collisions := game.detectCollisions
  let allEvents := List.append externalEvents collisions
  {
    camera := game.camera,
    player := game.player.update delta allEvents
    scoreboard := game.scoreboard.update delta allEvents
    ocean := game.ocean.update delta allEvents
  }

def Game.render (game: Game): IO Unit := do
  clearBackground Color.Raylib.lightgray
  renderWithCamera2D game.camera.camera do
    game.entities.render
  return ()

end Game
