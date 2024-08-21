import «Raylib»

import Examples.JessicaCantSwim.Entity

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

def Scoreboard.update (entity: Scoreboard) (msg: Entity.Msg) : Scoreboard :=
  match msg with
  | Entity.Msg.Collision Entity.ID.Ocean Entity.ID.Player => { entity with inOcean := True }
  | Entity.Msg.Collision Entity.ID.WetSand Entity.ID.Player => { entity with onWetsand := True }
  | Entity.Msg.Collision (Entity.ID.Shell _) Entity.ID.Player =>
    if !entity.inOcean
    then { entity with
      score := entity.score + 10,
    } else entity
  | Entity.Msg.Time delta =>
    if !entity.inOcean && entity.onWetsand
    then { entity with
      onWetsand := False,
      score := entity.score + delta,
    }
    else entity
  | _otherwise => entity

def Scoreboard.emit (_entity: Scoreboard): List Entity.Msg := []

def Scoreboard.render (entity: Scoreboard): IO Unit := do
  let scoreText := reprStr (entity.score.toUInt64)
  if entity.inOcean then
    drawText ("Game Over! Top Score: " ++ scoreText) 10 10 24 Color.black
    return ()
  drawText scoreText 10 10 24 Color.black

instance : Entity.Entity Scoreboard where
  emit := Scoreboard.emit
  update := Scoreboard.update
  render := Scoreboard.render

end Scoreboard
