import Raylean
import ECS

open Raylean
open Raylean.Types
open ECS

namespace Orbital

structure Position where
  val : Vector2

structure Velocity where
  val : Vector2

structure OrbitPath where
  val : Array Vector2

structure Mass where
  val : Float

structure Selectable where
  selected : Bool

-- Brings `World` and `initWorld` into scope
makeWorldAndComponents Position Velocity OrbitPath Selectable Mass
