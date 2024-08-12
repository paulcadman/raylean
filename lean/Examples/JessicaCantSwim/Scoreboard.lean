import «Raylib»

import Examples.JessicaCantSwim.Entity

namespace Scoreboard

structure Scoreboard where
  private over: Bool

def init: Scoreboard :=
  { over := False}

def Scoreboard.id (_entity: Scoreboard): Entity.ID :=
  Entity.ID.Scoreboard

def Scoreboard.update' (entity: Scoreboard) (event: Entity.Event) : Scoreboard :=
  match event with
  | Entity.Event.Collision Entity.ID.Player Entity.ID.Ocean => { over := True }
  | Entity.Event.Collision Entity.ID.Ocean Entity.ID.Player => { over := True }
  | _otherwise => entity

def Scoreboard.update (entity: Scoreboard) (_delta : Float) (events: List Entity.Event) : Id Scoreboard := do
  let mut entity := entity
  for event in events do
    entity := entity.update' event
  return entity

def Scoreboard.bounds (_entity: Scoreboard): Rectangle :=
  {
    x := 0,
    y := 0,
    width := 0,
    height := 0,
  }

def Scoreboard.render (entity: Scoreboard): IO Unit := do
  if entity.over
    then drawText "Game Over" 10 10 24 Color.black
  return ()

instance : Entity.Entity Scoreboard where
  id := Scoreboard.id
  update := Scoreboard.update
  bounds := Scoreboard.bounds
  render := Scoreboard.render

end Scoreboard
