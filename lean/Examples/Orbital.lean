import Raylean
import ECS

open Raylean
open Raylean.Types
open ECS

namespace Orbital

structure Camera where
  camera : Camera2D

structure Position where
  val : Vector2

structure Velocity where
  val : Vector2

inductive Dynamic :=
  | Dynamic

-- Brings `World` and `initWorld` into scope
makeWorldAndComponents Camera Position Velocity Dynamic

def init : System World Unit := do
  initWindow 1920 1080 "Orbital"
  setTargetFPS 60

def terminate : System World Unit := closeWindow

def update : System World Unit := return ()

def render : System World Unit :=
  renderFrame do
    clearBackground Color.black

def run : System World Unit := do
  while not (← windowShouldClose) do
    update
    render

def main : IO Unit := do
  runSystem (init *> run *> terminate) (← initWorld)
