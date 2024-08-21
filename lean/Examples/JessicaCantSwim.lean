import «Raylib»

import Examples.JessicaCantSwim.Game
import Examples.JessicaCantSwim.Keys
import Examples.JessicaCantSwim.Entity

namespace JessicaCantSwim

def rands (msgs: List Entity.Msg) : IO (List Entity.Msg) := do
  let mut rs := #[]
  for msg in msgs do
    match msg with
    | Entity.Msg.RequestRand id max =>
      let r ← IO.rand 0 max
      rs := rs.push (Entity.Msg.ResponseRand id r)
    | Entity.Msg.RequestRandPair id (max1, max2) =>
      let r1 ← IO.rand 0 max1
      let r2 ← IO.rand 0 max2
      rs := rs.push (Entity.Msg.ResponseRandPair id (r1, r2))
    | _otherwise =>
      continue
  return rs.toList

def main : IO Unit := do
  let screenWidth: Nat := 800
  let screenHeight : Nat := 450
  let startPosition : Vector2 := { x := 200, y := 200 }
  initWindow screenWidth screenHeight "Jessica Can't Swim"
  setTargetFPS 60
  let mut game := Game.init startPosition screenWidth screenHeight
  while not (← windowShouldClose) do
    let delta ← getFrameTime
    let keys ← Keys.getKeys
    let emits := game.emit
    let randMsgs ← rands emits
    let events: List Entity.Msg := List.map (λ key => Entity.Msg.Key key) keys
    game := game.step delta (List.join [events, emits, randMsgs])
    renderFrame do
      game.render
  closeWindow

end JessicaCantSwim
