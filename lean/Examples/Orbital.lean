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

def mkOrbitingBody (initPosition initVelocity : Vector2) : System World Unit :=
  newEntityAs_ (Position × Velocity × OrbitPath) ⟨⟨initPosition⟩, ⟨initVelocity⟩, ⟨#[]⟩⟩

def mkPlayer (initPosition initVelocity : Vector2) : System World Unit :=
  newEntityAs_ (Position × Velocity × OrbitPath × Player) ⟨⟨initPosition⟩, ⟨initVelocity⟩, ⟨#[]⟩, .Player⟩

def mkStaticBody (mass : Float) (position : Vector2) : System World Unit :=
  newEntityAs_ (Mass × Position × Not Velocity) (⟨mass⟩, ⟨position⟩, .Not)

def init : System World Unit := do

  mkStaticBody 1 origin
  mkStaticBody 0.5 (origin.add ⟨3, 3⟩)
  mkStaticBody 0.5 (origin.add ⟨-1, 3⟩)
  mkStaticBody 0.5 (origin.add ⟨-4, -4⟩)
  mkPlayer initPos initVel
  mkOrbitingBody ⟨-4, 0⟩ (initVel.mul (-1))
  mkOrbitingBody ⟨-0.8, -0.6⟩ (initVel.mul (-0.95))
  mkOrbitingBody ⟨1, 1⟩ (initVel.mul (-1))

  initWindow screenWidth screenHeight "Orbital"
  setTargetFPS 60

def terminate : System World Unit := closeWindow

def updateWithStatic (dt : Float) (staticBodies : Array (Mass × Position)) : Position × Velocity × OrbitPath → Position × Velocity × OrbitPath
  | ⟨⟨po⟩, ⟨v⟩, ⟨o⟩⟩ => Id.run do
    -- compute the new velocity from contributions from each static body
    let mut vNew := v
    for (⟨m⟩, ⟨ps⟩) in staticBodies do
      -- p is the vector pointing from the oribiting body (po) to the static body (ps)
      let p := ps.sub po
      let pMag := p.length
      let a := p |>.mul (m / pMag^3)
      vNew := vNew.add (a.mul dt)
    let pNew := po.add (vNew.mul dt)
    let oNew := o.push pNew
    (⟨pNew⟩, ⟨vNew⟩, ⟨oNew⟩)

def updateOrbitingBody (dt : Float) : System World Unit := do
  let static : Array (Mass × Position × Not Velocity) ← members
  cmap (updateWithStatic dt (static.map (fun (m, p, _) => (m, p))))

def changeVelocity (dv : Float) : Velocity × Player → Velocity
 | (⟨v⟩, _) => ⟨v.add <| v.mul (dv / v.length)⟩

def changePerpVelocity (dv : Float) : Velocity × Player → Velocity
 | (⟨v⟩, _) =>
   let normV : Vector2 := ⟨-v.y, v.x⟩
   ⟨v.add <| normV.mul (dv / v.length)⟩

def resetOrbitPath (_ : OrbitPath) : OrbitPath := OrbitPath.mk #[]

def resetPlayer : Position × Velocity × OrbitPath × Player → Position × Velocity × OrbitPath
  | (_, _, _, _) => (⟨initPos⟩, ⟨initVel⟩, OrbitPath.mk #[])

def update : System World Unit := do
  if (← isKeyDown Key.up) then cmap (changeVelocity 0.01)
  if (← isKeyDown Key.down) then cmap (changeVelocity (-0.01))
  if (← isKeyDown Key.right) then cmap (changePerpVelocity (0.01))
  if (← isKeyDown Key.left) then cmap (changePerpVelocity (-0.01))
  if (← isKeyDown Key.space) then cmap resetOrbitPath
  if (← isKeyDown Key.r) then cmap resetPlayer
  updateOrbitingBody (← getFrameTime)

/-- Convert a Position to a point on the screen --/
def toScreen (v : Vector2) : Vector2 :=
  v.mul 100 |>.add center

def renderStaticBody (mass : Mass) (p : Position) : System World Unit :=
    drawCircleV (toScreen p.val) (mass.val * 30) Color.red

def renderOrbitingBody (p : Position) (c : Color) : System World Unit :=
  drawCircleV (toScreen p.val) 10 c

def renderOrbitPath (o : OrbitPath) : System World Unit :=
  let arr := o.val
  for (s, e) in arr.zip (arr.extract 1 arr.size) do
    drawLineV (toScreen s) (toScreen e) Color.white

def render : System World Unit :=
  renderFrame do
    clearBackground Color.black
    cmapM_ (cx := Mass × Position × Not Velocity) <| fun (m, p, _) => renderStaticBody m p
    cmapM_ (cx := Position × Velocity × Player) <| fun (p, _, _) => renderOrbitingBody p Color.green
    cmapM_ (cx := Position × Velocity × Not Player) <| fun (p, _, _) => renderOrbitingBody p Color.blue
    cmapM_ renderOrbitPath

def run : System World Unit := do
  while not (← windowShouldClose) do
    update
    render

def main : IO Unit := do
  runSystem (init *> run *> terminate) (← initWorld)
