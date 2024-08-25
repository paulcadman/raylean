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
  | Bounds (id: ID) (boxes: List Rectangle): Msg
  | Collision (src: ID) (dst: ID) : Msg
  | Key (key: Keys.Keys) : Msg
  | Time (delta: Float): Msg

  | RequestRand (id: ID) (max: Nat): Msg
  | ResponseRand (id: ID) (r: Nat): Msg
  | RequestRandPair (id: ID) (max: (Nat × Nat)): Msg
  | ResponseRandPair (id: ID) (r: (Nat × Nat)): Msg

  | OceanPullingBack (max: Float): Msg

class Model (M : Type u) where
  emit (model: M): List Msg
  update (model: M) (msg: Msg) : M
  render (model: M): List Draw.Draw

end Types
