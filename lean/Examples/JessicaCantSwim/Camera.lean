import Raylib.Types

namespace Examples.JessicaCantSwim.Camera

structure Camera where
  camera : Camera2D

def Camera.init (target: Vector2) (screenWidth: Nat) (screenHeight: Nat): Camera :=
  {
    camera := {
      target := target,
      offset := {
        x := screenWidth.toFloat / 2,
        y := screenHeight.toFloat / 2,
      }
      rotation := 0,
      zoom := 1,
    }
  }

end Examples.JessicaCantSwim.Camera
