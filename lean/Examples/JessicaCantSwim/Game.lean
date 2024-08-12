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
  entities : Entity.Entities

def init (position: Vector2) (screenWidth: Nat) (screenHeight: Nat): Game :=
  let camera := Camera.init position screenWidth screenHeight

  let player := Entity.wrap <| Player.init position
  let scoreboard := Entity.wrap <| Scoreboard.init
  let ocean := Entity.wrap <| Ocean.init screenWidth screenHeight
  let entities := [player, scoreboard, ocean]

  {
    camera := camera,
    entities := entities,
  }

def Game.detectCollisions (game: Game): List Entity.Event :=
  let idBoundPairs : List (Entity.ID × List Rectangle) :=
    List.map (λ entity => (entity.id, entity.bounds)) game.entities
  let collisions := Collision.detects idBoundPairs
  List.map (λ collision => Entity.Event.Collision collision.1 collision.2) collisions

def Game.update (game: Game) (delta : Float) (events: List Entity.Event): Game :=
  let collisions := game.detectCollisions
  let allEvents := List.append events collisions
  let updatedEntities := List.map (λ entity => entity.update delta allEvents) game.entities
  {
    camera := game.camera,
    entities := updatedEntities
  }

def Game.render (game: Game): IO Unit := do
  clearBackground Color.Raylib.lightgray
  renderWithCamera2D game.camera.camera do
    game.entities.render
  return ()

end Game
