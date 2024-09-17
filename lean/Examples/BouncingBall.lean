import Raylean
import ECS

open Raylean
open Raylean.Types
open ECS

namespace BouncingBall

structure Position where
  val : Vector2

structure Velocity where
  val : Vector2

structure Config where
  shapeRadius : Float
  screenWidth : Float
  screenHeight : Float
  velocity : Vector2

inductive Circle :=
  | Circle

-- Brings `World` and `initWorld` into scope
makeWorldAndComponents Position Velocity Config Circle

def init : System World Unit := do
  let screenWidth := 800
  let screenHeight := 600
  set' global
    { shapeRadius := 20
    , screenWidth := screenWidth.toFloat
    , screenHeight := screenHeight.toFloat
    , velocity := ⟨300, 250⟩
    : Config
    }
  initWindow screenWidth screenHeight "Bouncing ball"
  setTargetFPS 120

def newBall (p : Vector2) : System World Unit := do
  let c : Config ← get global
  newEntityAs_ (Position × Velocity × Circle) (⟨p⟩, ⟨c.velocity⟩, .Circle)

def newSquare (p : Vector2) : System World Unit := do
  let c : Config ← get global
  newEntityAs_ (Position × Velocity × Not Circle) (⟨p⟩, ⟨c.velocity.mul (-1)⟩, .Not)

def renderBall : Position × Circle → System World Unit
  | (⟨p⟩, _) => do
    let c : Config ← get global
    drawCircleV p c.shapeRadius Color.Raylean.maroon

def renderSquare : Position × Not Circle → System World Unit
  | (⟨p⟩, _) => do
    let c : Config ← get global
    drawRectangleRec ⟨p.x - c.shapeRadius, p.y - c.shapeRadius, 2 * c.shapeRadius, 2 * c.shapeRadius⟩ Color.Raylean.green

def updateShape (dt : Float) (c : Config) : Position × Velocity → Position × Velocity
  | (⟨p⟩, ⟨v⟩) =>
    let position := p.add (v.mul dt)
    let velocity : Vector2 :=
      ⟨
        if position.x >= c.screenWidth - c.shapeRadius || position.x <= c.shapeRadius then v.x * (-1.0) else v.x,
        if position.y >= c.screenHeight - c.shapeRadius || position.y <= c.shapeRadius then v.y * (-1.0) else v.y
      ⟩
    (⟨position⟩, ⟨velocity⟩)

def removeAll (_ : Position) : Not Position := .Not

def deleteAt (pos : Vector2) (radius : Float) : Position → System World (Option Position)
  | ⟨p⟩ => do if
    (← checkCollisionPointRec pos {x := p.x - radius, y := p.y - radius, width := 2 * radius, height := 2 * radius : Rectangle})
    then return none else return (some ⟨p⟩)

/-- An alternative to `deleteAt` that explicitly deletes an entity --/
def deleteAt' (pos : Vector2) (radius : Float) : Position × Entity → System World Unit
  | (⟨p⟩, e) => do if
    (← checkCollisionPointRec pos {x := p.x - radius, y := p.y - radius, width := 2 * radius, height := 2 * radius : Rectangle})
    then destroy (Position × Velocity) e else return ()

def update : System World Unit := do
  let c : Config ← get global
  if (← isMouseButtonPressed MouseButton.left) then
    if (← isKeyDown Key.r) then cmapM (deleteAt (← getMousePosition) c.shapeRadius)
                           else newBall (← getMousePosition)
  if (← isMouseButtonPressed MouseButton.right) then newSquare (← getMousePosition)
  if (← isKeyDown Key.space) then cmap removeAll
  cmap (updateShape (← getFrameTime) c)

def render : System World Unit := do
  renderFrame do
    clearBackground Color.white
    cmapM_ renderBall
    cmapM_ renderSquare

def run : System World Unit := do
  while not (← windowShouldClose) do
    update
    render

def terminate : System World Unit := closeWindow

def main : IO Unit := do
  runSystem (init *> run *> terminate) (← initWorld)
