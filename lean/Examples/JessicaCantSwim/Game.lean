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
  player : Player.Player
  scoreboard : Scoreboard.Scoreboard
  ocean : Ocean.Ocean

def init (position: Vector2) (screenWidth: Nat) (screenHeight: Nat): Game :=
  let camera := Camera.init position screenWidth screenHeight
  let player := Player.init position
  let scoreboard := Scoreboard.init
  let ocean := Ocean.init screenWidth screenHeight
  {
    camera := camera,
    player := player,
    scoreboard := scoreboard,
    ocean := ocean,
  }

def Game.detectCollisions (game: Game): List Entity.Event :=
  let entities : List (Entity.ID × List Rectangle) :=
    [
      (game.player.id, game.player.bounds),
      (game.scoreboard.id, game.scoreboard.bounds),
      (game.ocean.id, game.ocean.bounds),
    ]
  let collisions := Collision.detects entities
  List.map (λ collision => Entity.Event.Collision collision.1 collision.2) collisions

def Game.update (game: Game) (delta : Float) (events: List Entity.Event): Game :=
  let collisions := game.detectCollisions
  let allEvents := List.append events collisions
  {
    camera := game.camera,
    player := game.player.update delta allEvents,
    ocean := game.ocean.update delta allEvents,
    scoreboard := game.scoreboard.update delta allEvents,
  }

def Game.render (game: Game): IO Unit := do
  clearBackground Color.Raylib.lightgray
  renderWithCamera2D game.camera.camera do
    game.player.render
    game.ocean.render
    game.scoreboard.render
  return ()

end Game
