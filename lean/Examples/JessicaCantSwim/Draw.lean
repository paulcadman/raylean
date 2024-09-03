import Examples.JessicaCantSwim.Colors
import Examples.JessicaCantSwim.Shape

namespace Draw

inductive Draw where
| Text (text: String) (x: Nat) (y: Nat) (size: Nat) (color: Colors.Color)
| Rectangle (r: Shape.Rectangle) (color: Colors.Color)
| Circle (circle: Shape.Circle) (color: Colors.Color)

end Draw
