import Examples.JessicaCantSwim.Keys

namespace Entity

inductive ID where
  | All
  | Player
  | Scoreboard
  | Ocean
  deriving BEq

inductive Event where
  | Collision (src: ID) (dst: ID) : Event
  | Key (key: Keys.Keys) : Event

class Entity (E : Type u) where
  id (entity: E): ID
  update (entity: E) (delta : Float) (events: List Event) : E
  bounds (entity: E): List Rectangle
  render (entity: E): IO Unit

inductive Elem where
  | mk (elem: Σ α, Entity α × α): Elem

def Entities := List Elem

def wrap [Entity E] (e: E): Elem :=
  Elem.mk ⟨ E, ⟨ inferInstance, e ⟩ ⟩

def Elem.id (elem: Elem): ID :=
  match elem with
  | Elem.mk ⟨_, ⟨_, entity ⟩ ⟩ => Entity.id entity

def Elem.bounds (elem: Elem): List Rectangle :=
  match elem with
  | Elem.mk ⟨_, ⟨_, entity ⟩ ⟩ => Entity.bounds entity

def Elem.render (elem: Elem): IO Unit :=
  match elem with
  | Elem.mk ⟨_, ⟨_, entity ⟩ ⟩ => Entity.render entity

def Elem.update (elem: Elem) (delta : Float) (events: List Event) : Elem :=
  match elem with
  | Elem.mk ⟨_, ⟨_, entity ⟩ ⟩ => wrap <| Entity.update entity delta events

instance : Entity Elem where
  id := Elem.id
  update := Elem.update
  bounds := Elem.bounds
  render := Elem.render

def Entities.forM [Monad m] : Entities → (Elem → m PUnit) → m PUnit
  | [], _ => pure ()
  | x :: xs, action => do
    action x
    forM xs action

instance : ForM m Entities Elem where
  forM := Entities.forM

def Entities.id (_entities: Entities): ID :=
  ID.All

def Entities.bounds (entities: Entities): List Rectangle :=
  match entities with
  | [] => []
  | x :: xs => List.append x.bounds (Entities.bounds xs)

def Entities.render (entities: Entities): IO Unit :=
  forM entities (λ elem => elem.render)

def Entities.update (entities: Entities) (delta : Float) (events: List Event) : Entities :=
  List.map (λ entity => entity.update delta events) entities

instance : Entity Entities where
  id := Entities.id
  update := Entities.update
  bounds := Entities.bounds
  render := Entities.render

end Entity
