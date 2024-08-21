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

def Scoreboard.id (_entity: Scoreboard): Entity.ID :=
  Entity.ID.Scoreboard

def Scoreboard.update (entity: Scoreboard) (msg: Entity.Msg) : Scoreboard :=
  match msg with
  | Entity.Msg.Collision Entity.ID.Player Entity.ID.Ocean => { entity with inOcean := True }
  | Entity.Msg.Collision Entity.ID.Ocean Entity.ID.Player => { entity with inOcean := True }
  | Entity.Msg.Collision Entity.ID.Player Entity.ID.WetSand => { entity with onWetsand := True }
  | Entity.Msg.Collision Entity.ID.WetSand Entity.ID.Player => { entity with onWetsand := True }
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
  if entity.inOcean then
    drawText "Game Over" 10 10 24 Color.black
    return ()
  let scoreText := reprStr (entity.score.toUInt64)
  drawText scoreText 10 10 24 Color.black

instance : Entity.Entity Scoreboard where
  id := Scoreboard.id
  emit := Scoreboard.emit
  update := Scoreboard.update
  render := Scoreboard.render

end Scoreboard
