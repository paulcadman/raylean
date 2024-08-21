import Raylib.Types

import Examples.JessicaCantSwim.Entity

namespace Collision

-- detect if there is a collision between two rectangles
private def detect(rect1: Rectangle) (rect2: Rectangle): Bool :=
  rect1.x < rect2.x + rect2.width &&
  rect1.x + rect1.width > rect2.x &&
  rect1.y < rect2.y + rect2.height &&
  rect1.y + rect1.height > rect2.y

def detects {EntityID: Type} (entities: List (EntityID × List Rectangle)): Id (List (EntityID × EntityID)) := do
  let mut collisions := #[]
  for src in entities do
    for dst in entities do
      for srcBound in src.2 do
        for dstBound in dst.2 do
          if detect srcBound dstBound then
            collisions := collisions.push (src.1, dst.1)
  return collisions.toList

-- detect if there is a collision between multiple entities
def detectEvents (entities: Entity.Entities): List Entity.Msg :=
  let idBoundPairs : List (Entity.ID × List Rectangle) := entities.idBoundPairs
  let collisions := Collision.detects idBoundPairs
  List.map (λ collision => Entity.Msg.Collision collision.1 collision.2) collisions

end Collision
