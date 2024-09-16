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
def initPos : Vector2 := ⟨5,0⟩
def initVel : Vector2 := ⟨0, 1.0 / initPos.length |>.sqrt⟩

def mkOrbitingBody (initPosition initVelocity : Vector2) (selected : Bool := false): System World Unit :=
  newEntityAs_ (Position × Velocity × OrbitPath × Selectable) ⟨⟨initPosition⟩, ⟨initVelocity⟩, ⟨#[]⟩, ⟨selected⟩⟩

def mkStaticBody (position : Vector2) : System World Unit :=
  newEntityAs_ (Position × Not Velocity) (⟨position⟩, .Not)

def init : System World Unit := do

  mkStaticBody origin
  mkOrbitingBody (selected := true) initPos initVel
  mkOrbitingBody ⟨-4, 0⟩ (initVel.mul (-1))
  mkOrbitingBody ⟨-0.8, -0.6⟩ (initVel.mul (-0.95))
  mkOrbitingBody ⟨1, 1⟩ (initVel.mul (-1))

  initWindow screenWidth screenHeight "Orbital"
  setTargetFPS 60

def terminate : System World Unit := closeWindow

def updateOrbitingBody (dt : Float) : Position × Velocity × OrbitPath → Position × Velocity × OrbitPath
  | (Position.mk p, Velocity.mk v, OrbitPath.mk o) =>
    let pMag := p.length
    let a := p |>.mul (-1 / pMag^3)
    let vNew := v.add (a.mul dt)
    let pNew := p.add (vNew.mul dt)
    let oNew := o.push pNew
    (⟨pNew⟩, ⟨vNew⟩, ⟨oNew⟩)

def changeSelectedVelocity (dv : Float) : Velocity × Selectable → Velocity
 | (Velocity.mk v, Selectable.mk true) => ⟨v.add <| v.mul (dv / v.length)⟩
 | (Velocity.mk v, Selectable.mk false) => ⟨v⟩

def changePerpVelocity (dv : Float) : Velocity × Selectable → Velocity
 | (Velocity.mk v, Selectable.mk true) =>
   let normV : Vector2 := ⟨-v.y, v.x⟩
   ⟨v.add <| normV.mul (dv / v.length)⟩
 | (Velocity.mk v, Selectable.mk false) => ⟨v⟩

def resetOrbitPath (_ : OrbitPath) : OrbitPath := OrbitPath.mk #[]

def resetSelected : Position × Velocity × OrbitPath × Selectable → Position × Velocity × OrbitPath
  | (_, _, _, Selectable.mk true) => (⟨initPos⟩, ⟨initVel⟩, OrbitPath.mk #[])
  | (p, v, o, _) => (p, v, o)

def update : System World Unit := do
  if (← isKeyDown Key.up) then cmap (changeSelectedVelocity 0.01)
  if (← isKeyDown Key.down) then cmap (changeSelectedVelocity (-0.01))
  if (← isKeyDown Key.right) then cmap (changePerpVelocity (0.01))
  if (← isKeyDown Key.left) then cmap (changePerpVelocity (-0.01))
  if (← isKeyDown Key.space) then cmap resetOrbitPath
  if (← isKeyDown Key.r) then cmap resetSelected
  cmap (updateOrbitingBody (← getFrameTime))

/-- Convert a Position to a point on the screen --/
def toScreen (v : Vector2) : Vector2 :=
  v.mul 100 |>.add center

def renderStaticBody (p : Position) : System World Unit :=
    drawCircleV (p.val.add center) 30 Color.red

def renderOrbitingBody (p : Position) (s : Selectable) : System World Unit :=
  drawCircleV (toScreen p.val) 10 (if s.selected then Color.green else Color.blue)

def renderOrbitPath (o : OrbitPath) : System World Unit :=
  let arr := o.val
  for (s, e) in arr.zip (arr.extract 1 arr.size) do
    drawLineV (toScreen s) (toScreen e) Color.white

def render : System World Unit :=
  renderFrame do
    clearBackground Color.black
    cmapM_ (cx := Position × Not Velocity) <| fun (p, _) => renderStaticBody p
    cmapM_ (cx := Position × Velocity × Selectable) <| fun (p, _, s) => renderOrbitingBody p s
    cmapM_ renderOrbitPath

def run : System World Unit := do
  while not (← windowShouldClose) do
    update
    render

def main : IO Unit := do
  runSystem (init *> run *> terminate) (← initWorld)
