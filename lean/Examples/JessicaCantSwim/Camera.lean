import Raylib.Types

namespace Examples.JessicaCantSwim.Camera

structure Camera where
  camera : Camera2D

def Camera.init (player: Vector2) (screenWidth: Nat) (screenHeight: Nat): Camera :=
  {
    camera := {
      target := {x := 0, y := 0},
      offset := {x := 0, y := 0},
      rotation := 0,
      zoom := 1,
    }
  }

end Examples.JessicaCantSwim.Camera
