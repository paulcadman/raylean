import Raylean
import ECS

open Raylean
open Raylean.Types
open ECS

namespace Orbital

structure Camera where
  val : Camera2D

structure Position where
  val : Vector2

structure Velocity where
  val : Vector2

-- Brings `World` and `initWorld` into scope
makeWorldAndComponents Camera Position Velocity
