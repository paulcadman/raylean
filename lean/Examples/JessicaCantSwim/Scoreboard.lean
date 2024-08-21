import «Raylib»

import Examples.JessicaCantSwim.Entity

namespace Scoreboard

structure Scoreboard where
  private over: Bool

def init: Scoreboard :=
  { over := False}

def Scoreboard.id (_entity: Scoreboard): Entity.ID :=
  Entity.ID.Scoreboard

def Scoreboard.update (entity: Scoreboard) (msg: Entity.Msg) : Scoreboard :=
  match msg with
  | Entity.Msg.Collision Entity.ID.Player Entity.ID.Ocean => { over := True }
  | Entity.Msg.Collision Entity.ID.Ocean Entity.ID.Player => { over := True }
  | _otherwise => entity

def Scoreboard.emit (_entity: Scoreboard): List Entity.Msg := []

def Scoreboard.bounds (_entity: Scoreboard): List Rectangle := []

def Scoreboard.render (entity: Scoreboard): IO Unit := do
  if entity.over
    then drawText "Game Over" 10 10 24 Color.black
  return ()

instance : Entity.Entity Scoreboard where
  id := Scoreboard.id
  emit := Scoreboard.emit
  update := Scoreboard.update
  bounds := Scoreboard.bounds
  render := Scoreboard.render

end Scoreboard
