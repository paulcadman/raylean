import Examples.JessicaCantSwim.Shape

namespace Camera

structure Camera where
  /-- Camera offset (displacement from target) -/
  offset : Shape.Vector2
  /-- Camera target (rotation and zoom origin) -/
  target : Shape.Vector2
  /-- Camera rotation in degrees -/
  rotation : Float
  /-- Camera zoom (scaling), should be 1.0f by default -/
  zoom : Float

def init (_player: Shape.Vector2) (_screenWidth: Nat) (_screenHeight: Nat): Camera :=
  {
    target := {x := 0, y := 0},
    offset := {x := 0, y := 0},
    rotation := 0,
    zoom := 1,
  }

end Camera
