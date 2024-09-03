import Examples.JessicaCantSwim.Shape
import Raylib

namespace Draw

inductive Draw where
| Text (text: String) (x: Nat) (y: Nat) (size: Nat) (color: Color)
| Rectangle (r: Shape.Rectangle) (color: Color)
| Circle (circle: Shape.Circle) (color: Color)

end Draw
