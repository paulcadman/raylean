import Examples.JessicaCantSwim.Keys

namespace Entity

inductive ID where
  | All
  -- Add your new Entity:
  | Player
  | Scoreboard
  | Ocean
  deriving BEq

inductive Event where
  -- Add your new Event:
  | Collision (src: ID) (dst: ID) : Event
  | Key (key: Keys.Keys) : Event

class Entity (E : Type u) where
  id (entity: E): ID
  update (entity: E) (delta : Float) (event: Event) : E
  bounds (entity: E): List Rectangle
  render (entity: E): IO Unit

inductive Elem.{u}: Type (u + 1) where
  | mk [Entity α] (elem: α): Elem

def wrap [Entity E] (e: E): Elem :=
  Elem.mk e

def Elem.id (elem: Elem): ID :=
  match elem with
  | Elem.mk entity => Entity.id entity

def Elem.bounds (elem: Elem): List Rectangle :=
  match elem with
  | Elem.mk entity => Entity.bounds entity

def Elem.render (elem: Elem): IO Unit :=
  match elem with
  | Elem.mk entity => Entity.render entity

def Elem.update (elem: Elem) (delta : Float) (event: Event) : Elem :=
  match elem with
  | Elem.mk entity => wrap <| Entity.update entity delta event

instance : Entity Elem where
  id := Elem.id
  update := Elem.update
  bounds := Elem.bounds
  render := Elem.render

inductive Entities where
  | mk (elems: List Elem): Entities

def Entities.forM [Monad m] : Entities → (Elem → m PUnit) → m PUnit
  | Entities.mk [], _ => pure ()
  | Entities.mk (x :: xs), action => do
    action x
    forM (Entities.mk xs) action

instance : ForM m Entities Elem where
  forM := Entities.forM

def Entities.id (_entities: Entities): ID := ID.All

def Entities.bounds (_entities: Entities): List Rectangle := []

def Entities.render (entities: Entities): IO Unit :=
  forM entities (λ elem => elem.render)

def Entities.update (entities: Entities) (delta : Float) (event: Event) : Entities :=
  match entities with
  | Entities.mk xs => Entities.mk <| List.map (λ entity => entity.update delta event) xs

instance : Entity Entities where
  id := Entities.id
  update := Entities.update
  bounds := Entities.bounds
  render := Entities.render

def Entities.idBoundPairs (entities: Entities) : List (ID × List Rectangle) :=
  match entities with
  | Entities.mk xs => List.map (λ entity: Elem => (entity.id, entity.bounds)) xs

end Entity
