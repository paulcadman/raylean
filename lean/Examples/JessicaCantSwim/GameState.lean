import Raylib.Types

import Examples.JessicaCantSwim.Player
import Examples.JessicaCantSwim.Keys
open Examples.JessicaCantSwim.Player
open Examples.JessicaCantSwim.Keys

namespace Examples.JessicaCantSwim.GameState

structure GameState where
  player : Player
  camera : Camera2D

abbrev GameM : Type -> Type := StateT GameState IO

def update (delta : Float) : GameM Unit := do
  let keys: List Keys <- getKeys
  let game: GameState <- get
  let player: Player := game.player
  let player': Player := player.update delta keys
  modify (fun s => { s with player := player' })
  return ()

def render: GameM Unit := do
  let game: GameState <- get
  let player: Player := game.player
  player.render
  return ()

end Examples.JessicaCantSwim.GameState
