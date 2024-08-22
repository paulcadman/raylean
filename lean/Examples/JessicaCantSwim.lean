import «Raylib»

import Examples.JessicaCantSwim.Types
import Examples.JessicaCantSwim.Keys
import Examples.JessicaCantSwim.Game

namespace JessicaCantSwim

def rands (msgs: List Types.Msg) : IO (List Types.Msg) := do
  let mut rs := #[]
  for msg in msgs do
    match msg with
    | Types.Msg.RequestRand id max =>
      let r ← IO.rand 0 max
      rs := rs.push (Types.Msg.ResponseRand id r)
    | Types.Msg.RequestRandPair id (max1, max2) =>
      let r1 ← IO.rand 0 max1
      let r2 ← IO.rand 0 max2
      rs := rs.push (Types.Msg.ResponseRandPair id (r1, r2))
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
    let events: List Types.Msg := List.map (λ key => Types.Msg.Key key) keys
    game := game.step delta (List.join [events, emits, randMsgs])
    renderFrame do
      game.render
  closeWindow

end JessicaCantSwim
