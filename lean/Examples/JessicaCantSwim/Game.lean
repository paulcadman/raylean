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

abbrev GameM : Type -> Type := StateT Game IO

def Game.update (delta : Float) : GameM Unit := do
  let keys: List Keys <- getKeys
  let game: Game <- get
  let player: Player := game.player
  let player': Player := player.update delta keys
  modify (fun s => { s with player := player' })
  return ()

def Game.render: GameM Unit := do
  let game: Game <- get
  let player: Player := game.player
  clearBackground Color.Raylib.lightgray
  renderWithCamera2D (← get).camera.camera do
    player.render
  return ()

end Examples.JessicaCantSwim.Game
