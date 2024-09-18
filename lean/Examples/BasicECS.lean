import Raylean
import ECS

open Raylean
open Raylean.Types
open ECS

namespace BasicECS

structure Camera where
  camera : Camera3D

-- Brings `World` and `initWorld` into scope
makeWorldAndMapComponents [Camera]

def init : System World Unit := do
  let mut camera : Camera3D := {
   position := ⟨5, 1, 0⟩,
   target := ⟨0, 0, 0⟩,
   up := ⟨0, 1, 0⟩,
   fovy := 70
   projection := .perspective}
  camera ← updateCamera camera CameraMode.firstPerson

  -- Create a global entity with the camera component
  -- `set'` sets a component's state for a given entity
  -- `global` refers to the unique global entity
  set' global <| Camera.mk camera

  initWindow 1920 1080 "App"
  setTargetFPS 60

def terminate : System World Unit := closeWindow

def update : System World Unit := do
  -- get the camera component from the global entity
  let (Camera.mk c) ← get global
  let c' ← updateCamera c CameraMode.firstPerson

  -- replace the global entity's camera with the updated Camera
  set' global <| Camera.mk c'

def render : System World Unit := do
  let (Camera.mk c) ← get global
  renderFrame do
      clearBackground Color.white
      renderWithCamera c do
        drawCube ⟨0,0,0⟩ 2 2 2 Color.red
        drawCubeWires ⟨0,0,0⟩ 2 2 2 Color.blue
        drawGrid 10 1
      drawFPS 10 20
      drawText "Welcome to the third dimension" 10 40 20 Color.black

def run : System World Unit := do
  while not (← windowShouldClose) do
    update
    render

def main : IO Unit := do
  runSystem (init *> run *> terminate) (← initWorld)
