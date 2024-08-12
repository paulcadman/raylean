import Examples.JessicaCantSwim.Keys

namespace Entity

inductive ID where
  | Player
  | Scoreboard
  | Ocean
  deriving BEq

inductive Event where
  | Collision (src: ID) (dst: ID) : Event
  | Key (key: Keys.Keys) : Event

class Entity (E : Type) where
  id (entity: E): ID
  update (entity: E) (delta : Float) (events: List Event) : E
  bounds (entity: E): List Rectangle
  render (entity: E): IO Unit

end Entity
