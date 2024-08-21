import «Raylib»
import Raylib.Types

import Examples.JessicaCantSwim.Entity

namespace WetSand

structure WetSand where
  private maxWidth: Float
  private height: Float
  private gravity: Float
  private countdown: Float
  private width: Float
  private speed: Float

def init (maxWidth: Nat) (height: Nat) : WetSand :=
  {
    maxWidth := maxWidth.toFloat,
    height := height.toFloat,
    gravity := 9.8,
    width := 0,
    speed := 0,
    countdown := 0,
  }

def WetSand.id (_entity: WetSand): Entity.ID :=
  Entity.ID.WetSand

private def WetSand.box (wetsand: WetSand): Rectangle :=
  {
    x := wetsand.maxWidth - wetsand.width,
    y := 0,
    width := wetsand.width,
    height := wetsand.height,
  }

def WetSand.emit (entity: WetSand): List Entity.Msg :=
  [ Entity.Msg.Bounds entity.id [entity.box] ]

def WetSand.update (wetsand: WetSand) (msg: Entity.Msg): Id WetSand := do
  match msg with
  | Entity.Msg.OceanPullingBack max =>
    if max < wetsand.width then
       -- Still pulling back from ocean that was out further
      return wetsand
    return {
        maxWidth := wetsand.maxWidth,
        height := wetsand.height,
        gravity := wetsand.gravity,
        countdown := 5,
        width := max,
        speed := 0,
      }
  | Entity.Msg.Time delta =>
    if wetsand.width <= 0 then return wetsand
    if wetsand.countdown > 0
    then
      return { wetsand with
        countdown := wetsand.countdown - delta
      }
    else
      let move := wetsand.speed * delta
      let width := wetsand.width + move
      let speed := wetsand.speed - wetsand.gravity * delta
      return {
        maxWidth := wetsand.maxWidth,
        height := wetsand.height,
        gravity := wetsand.gravity,
        countdown := 0,
        width := width,
        speed := speed,
      }
  | _otherwise =>
    return wetsand

def WetSand.render (wetsand: WetSand): IO Unit := do
  let rect: Rectangle := wetsand.box
  drawRectangleRec rect Color.red

instance : Entity.Entity WetSand where
  id := WetSand.id
  emit := WetSand.emit
  update := WetSand.update
  render := WetSand.render

end WetSand
