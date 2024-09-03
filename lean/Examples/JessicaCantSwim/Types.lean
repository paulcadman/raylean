import Examples.JessicaCantSwim.Keys
import Examples.JessicaCantSwim.Draw

namespace Types

inductive ID where
  | All
  -- Add your new Model here:
  | Player
  | Scoreboard
  | Ocean
  | WetSand
  | Shells
  | Shell (n: Nat)
  deriving BEq, Repr

inductive Msg where
  -- Add your new Message here:
  | Bounds (id: ID) (boxes: List Shape.Rectangle): Msg
  | Collision (src: ID) (dst: ID) : Msg
  | Key (key: Keys.Keys) : Msg
  | Time (delta: Float): Msg
  | OceanPullingBack (max: Float): Msg

class Model (M : Type u) where
  emit (model: M): List Msg
  update (model: M) (msg: Msg) : M
  view (model: M): List Draw.Draw

end Types
