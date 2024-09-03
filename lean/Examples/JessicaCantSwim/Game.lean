import Examples.JessicaCantSwim.Rand
import Examples.JessicaCantSwim.Types
import Examples.JessicaCantSwim.Camera

import Examples.JessicaCantSwim.Collision
import Examples.JessicaCantSwim.Player
import Examples.JessicaCantSwim.Scoreboard
import Examples.JessicaCantSwim.Ocean
import Examples.JessicaCantSwim.WetSand
import Examples.JessicaCantSwim.Shells

namespace Game

structure Game where
  camera : Camera.Camera
  -- Add your new Model here:
  player: Player.Player
  scoreboard: Scoreboard.Scoreboard
  ocean: Ocean.Ocean
  wetsand: WetSand.WetSand
  shells: Shells.Shells

def init (r: Rand.Generator) (position: Shape.Vector2) (screenWidth: Nat) (screenHeight: Nat): Game :=
  let camera := Camera.init position screenWidth screenHeight
  let (oceanRand, shellsRand) := r.split
  {
    camera := camera,
    -- Add your new Model here:
    player := Player.init position,
    scoreboard := Scoreboard.init,
    ocean := Ocean.init screenWidth screenHeight oceanRand,
    wetsand := WetSand.init screenWidth screenHeight,
    shells := Shells.init screenWidth screenHeight shellsRand,
  }

private def Game.update (game: Game) (msg: Types.Msg): Game :=
  {
    camera := game.camera,
    -- Add your new Model here:
    player := game.player.update msg
    scoreboard := game.scoreboard.update msg
    ocean := game.ocean.update msg
    wetsand := game.wetsand.update msg
    shells := game.shells.update msg
  }

def Game.view (game: Game): List Draw.Draw :=
  List.join [
    -- Add your new Model here:
    game.wetsand.view,
    game.shells.view,
    game.ocean.view,
    game.player.view,
    game.scoreboard.view,
  ]

def Game.emit (game: Game): List Types.Msg :=
  List.join [
    -- Add your new Model here:
    game.ocean.emit,
    game.wetsand.emit,
    game.shells.emit,
    game.player.emit,
    game.scoreboard.emit
  ]

private def Game.updates (game: Game) (events: List Types.Msg): Id Game := do
  let mut game := game
  for event in events do
    game := game.update event
  return game

def Game.step (game: Game) (delta : Float) (externalEvents: List Types.Msg): Game :=
  let collisions := Collision.detectCollisions externalEvents
  let deltaEvent := Types.Msg.Time delta
  let allEvents := List.concat (List.append externalEvents collisions) deltaEvent
  Game.updates game allEvents

end Game
