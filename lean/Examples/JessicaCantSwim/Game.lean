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

private def Game.update (game: Game) (msg: Entity.Msg): Game :=
  {
    camera := game.camera,
    -- Add your new Entity here:
    player := game.player.update msg
    scoreboard := game.scoreboard.update msg
    ocean := game.ocean.update msg
  }

def Game.render (game: Game): IO Unit := do
  clearBackground Color.Raylib.lightgray
  renderWithCamera2D game.camera.camera do
    -- Add your new Entity here:
    game.ocean.render
    game.player.render
    game.scoreboard.render
  return ()

def Game.emit (game: Game): List Entity.Msg :=
  List.join [
    -- Add your new Entity here:
    game.ocean.emit,
    game.player.emit,
    game.scoreboard.emit
  ]

private def Game.updates (game: Game) (events: List Entity.Msg): Id Game := do
  let mut game := game
  for event in events do
    game := game.update event
  return game

def Game.step (game: Game) (delta : Float) (externalEvents: List Entity.Msg): Game :=
  let collisions := Collision.detectCollisions externalEvents
  let deltaEvent := Entity.Msg.Time delta
  let allEvents := List.concat (List.append externalEvents collisions) deltaEvent
  Game.updates game allEvents

end Game
