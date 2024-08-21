import Examples.JessicaCantSwim.Keys

namespace Entity

inductive ID where
  | All
  -- Add your new Entity here:
  | Player
  | Scoreboard
  | Ocean
  | WetSand
  deriving BEq, Repr

inductive Msg where
  -- Add your new Message here:
  | Bounds (id: ID) (boxes: List Rectangle): Msg
  | Collision (src: ID) (dst: ID) : Msg
  | Key (key: Keys.Keys) : Msg
  | Time (delta: Float): Msg
  | RequestRand (id: ID): Msg
  | Rand (id: ID) (r: Nat): Msg
  | OceanPullingBack (max: Float): Msg

class Entity (E : Type u) where
  emit (entity: E): List Msg
  update (entity: E) (msg: Msg) : E
  render (entity: E): IO Unit

end Entity
