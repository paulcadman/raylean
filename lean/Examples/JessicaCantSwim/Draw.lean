import «Raylib»

namespace Draw

inductive Draw where
| Text (text: String) (x: Nat) (y: Nat) (size: Nat) (color: Color)
| Rectangle (r: Rectangle) (color: Color)
| Circle (position: Vector2) (radius: Float) (color: Color)

end Draw
