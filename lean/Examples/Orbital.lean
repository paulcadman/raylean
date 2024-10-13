import Raylean
import ECS
import Examples.Orbital.Types
import Raylean.Graphics2D

open Raylean
open Raylean.Types
open ECS
open Raylean.Graphics2D

namespace Orbital

def screenWidth : Nat := 1920
def screenHeight : Nat := 1080
def initPos : Vector2 := ⟨5,0⟩
def initVel : Vector2 := ⟨0, 1.0 / initPos.length |>.sqrt |>.neg⟩

def mkOrbitingBody (initPosition initVelocity : Vector2) : System World Unit :=
  newEntityAs_ (Position × Velocity × OrbitPath) ⟨⟨initPosition⟩, ⟨initVelocity⟩, ⟨#[]⟩⟩

def mkPlayer (initPosition initVelocity : Vector2) : System World Unit :=
  newEntityAs_ (Position × Velocity × OrbitPath × Player) ⟨⟨initPosition⟩, ⟨initVelocity⟩, ⟨#[]⟩, .Player⟩

def mkStaticBody (mass : Float) (position : Vector2) : System World Unit :=
  newEntityAs_ (Mass × Position × Not Velocity) (⟨mass⟩, ⟨position⟩, .Not)

def init : System World Unit := do

  mkStaticBody 1 ⟨0,0⟩
  mkStaticBody 0.5 ⟨3, -3⟩
  mkStaticBody 0.5 ⟨-1, -3⟩
  mkStaticBody 0.5 ⟨-4, 4⟩
  mkPlayer initPos initVel
  mkOrbitingBody ⟨-4, 0⟩ (initVel.mul (-1))
  mkOrbitingBody ⟨-0.8, 0.6⟩ (initVel.mul (-0.95))
  mkOrbitingBody ⟨1, 1⟩ initVel

  initWindow screenWidth screenHeight "Orbital"
  setTargetFPS 60

def updateWithStatic (dt : Float) (staticBodies : Array (Mass × Position)) : Position × Velocity × OrbitPath → Position × Velocity × OrbitPath
  | ⟨⟨po⟩, ⟨v⟩, ⟨o⟩⟩ => Id.run do
    -- compute the new velocity from contributions from each static body
    let mut vNew := v
    for (⟨m⟩, ⟨ps⟩) in staticBodies do
      -- p is the vector pointing from the oribiting body (po) to the static body (ps)
      let p := ps.sub po
      let pMag := p.length
      let softenedDistance := (pMag^2 + 0.25^2).sqrt
      let a := p |>.mul (m / softenedDistance^3)
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
  if (← isKeyDown Key.right) then cmap (changePerpVelocity (-0.01))
  if (← isKeyDown Key.left) then cmap (changePerpVelocity (0.01))
  if (← isKeyDown Key.space) then cmap resetOrbitPath
  if (← isKeyDown Key.r) then cmap resetPlayer
  updateOrbitingBody (← getFrameTime)

def bodyScale (mass : Mass) : Float := mass.val * 0.3

def staticBody (mass : Mass) (p : Position) : Picture :=
  .circle (bodyScale mass) |>
  .color .red |>
  .translate p.val

def orbitingBody (p : Position) (c : Color) : Picture :=
  .circle 0.1 |>
  .color c |>
  .translate p.val

def orbitPath (o : OrbitPath) : Picture :=
  .line o.val |> .color .white

def gamePicture : System World Picture := do
  let staticBodies ← collect (cx := Mass × Position × Not Velocity) <| fun (m, p, _) => staticBody m p |> some
  let playerOrbitingBody ← collect (cx := Player × Position × Velocity) <| fun (_, p, _) => orbitingBody p .green |> some
  let orbitingBodies ← collect (cx := Position × Velocity × Not Player) <| fun (p, _, _) => orbitingBody p .blue |> some
  let orbitPaths ← collect <| some ∘ orbitPath
  return (.scale ⟨100, 100⟩ <| .pictures (staticBodies ++ playerOrbitingBody ++ orbitingBodies ++ orbitPaths))

def render : System World Unit :=
  renderFrame do
    clearBackground Color.black
    renderPicture screenWidth.toFloat screenHeight.toFloat (← gamePicture)

def terminate : System World Unit := closeWindow

def run : System World Unit := do
  while not (← windowShouldClose) do
    update
    render

def main : IO Unit := do
  runSystem (init *> run *> terminate) (← initWorld)
