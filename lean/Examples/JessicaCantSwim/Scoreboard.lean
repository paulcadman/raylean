import «Raylib»

import Examples.JessicaCantSwim.Types

namespace Scoreboard

structure Scoreboard where
  private inOcean: Bool
  private onWetsand: Bool
  private score: Float

def init: Scoreboard :=
  {
    inOcean := False,
    onWetsand := False,
    score := 0,
  }

def Scoreboard.update (scoreboard: Scoreboard) (msg: Types.Msg) : Scoreboard :=
  match msg with
  | Types.Msg.Collision Types.ID.Ocean Types.ID.Player => { scoreboard with inOcean := True }
  | Types.Msg.Collision Types.ID.WetSand Types.ID.Player => { scoreboard with onWetsand := True }
  | Types.Msg.Collision (Types.ID.Shell _) Types.ID.Player =>
    if !scoreboard.inOcean
    then { scoreboard with
      score := scoreboard.score + 10,
    } else scoreboard
  | Types.Msg.Time delta =>
    if !scoreboard.inOcean && scoreboard.onWetsand
    then { scoreboard with
      onWetsand := False,
      score := scoreboard.score + delta,
    }
    else scoreboard
  | _otherwise => scoreboard

def Scoreboard.emit (_scoreboard: Scoreboard): List Types.Msg := []

def Scoreboard.render (scoreboard: Scoreboard): Id (List (Draw.Draw)) := do
  let scoreText := reprStr (scoreboard.score.toUInt64)
  if scoreboard.inOcean then
    return [Draw.Draw.Text ("Game Over! Top Score: " ++ scoreText) 10 10 24 Color.black]
  return [Draw.Draw.Text scoreText 10 10 24 Color.black]

instance : Types.Model Scoreboard where
  emit := Scoreboard.emit
  update := Scoreboard.update
  render := Scoreboard.render

end Scoreboard
