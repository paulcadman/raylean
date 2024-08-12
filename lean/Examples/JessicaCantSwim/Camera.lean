import Raylib.Types

namespace Camera

structure Camera where
  camera : Camera2D

def init (player: Vector2) (screenWidth: Nat) (screenHeight: Nat): Camera :=
  {
    camera := {
      target := {x := 0, y := 0},
      offset := {x := 0, y := 0},
      rotation := 0,
      zoom := 1,
    }
  }

end Camera
