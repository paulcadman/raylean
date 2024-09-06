import Raylean
import ECS
import Examples.Orbital.Types

open Raylean
open Raylean.Types
open ECS

namespace Orbital

def screenWidth : Nat := 1920
def screenHeight : Nat := 1080
def center : Vector2 := ⟨screenWidth.toFloat / 2, screenHeight.toFloat / 2⟩
def origin : Vector2 := ⟨0,0⟩

def init : System World Unit := do
  let camera : Camera := ⟨center, center, 0, 1⟩
  set' global camera

  let initPos : Vector2 := ⟨5,0⟩
  let initVel : Vector2 := ⟨0, 1.0 / initPos.length |>.sqrt⟩

  newEntityAs_ (Position × Not Velocity) (⟨origin⟩, .Not)
  newEntityAs_ (Position × Velocity) ⟨⟨initPos⟩, ⟨initVel⟩⟩
  newEntityAs_ (Position × Velocity) ⟨⟨-4, 0⟩, ⟨initVel.mul (-1)⟩⟩
  newEntityAs_ (Position × Velocity) ⟨⟨2, 2⟩, ⟨initVel.mul (-1)⟩⟩
  initWindow screenWidth screenHeight "Orbital"
  setTargetFPS 60

def terminate : System World Unit := closeWindow

def update : System World Unit := do
  let dt ← getFrameTime
  cmap (cx := Position × Velocity) <| fun (p, v) =>
    let pv := p.val
    let pMag := pv.length
    let a := pv |>.mul (-1 / pMag^3)
    let vv := v.val
    let vvNew := vv.add (a.mul dt)
    let pvNew := pv.add (vvNew.mul dt)
    let pNew : Position := ⟨pvNew⟩
    let vNew : Velocity := ⟨vvNew⟩
    (pNew, vNew)

def render : System World Unit :=
  renderFrame do
    drawFPS 10 20
    clearBackground Color.black
    cmapM_ (cx := Position × Not Velocity) <| fun (p, _) => do
      drawCircleV (p.val.add center) 30 Color.red
    cmapM_ (cx := Position × Velocity) <| fun (p, _) => do
      drawCircleV (p.val.mul 100 |>.add center) 10 Color.blue

def run : System World Unit := do
  while not (← windowShouldClose) do
    update
    render

def main : IO Unit := do
  runSystem (init *> run *> terminate) (← initWorld)
