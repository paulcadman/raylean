import Raylean.Types
import Raylean.Core
import Batteries

namespace Raylean.Image

abbrev Vector2 := Raylean.Types.Vector2

structure Color where
  r : Rat
  g : Rat
  b : Rat
  -- alpha is between 0 and 1
  -- TODO: This should be part of the type
  alpha : Rat

def Color.transparent : Color := ⟨0, 0, 0, 0⟩
def redish := { r:=255, g:=0, b:=0, alpha :=0.25 : Color }
def bluish := { r:=0, g:=0, b:=255, alpha :=0.5 : Color }

def toRaylean (c : Color) : Raylean.Types.Color := ⟨c.r.toFloat.toUInt8, c.g.toFloat.toUInt8, c.b.toFloat.toUInt8, c.alpha * 255 |>.toFloat.toUInt8 ⟩

structure Location where
  x : Rat
  y : Rat

def Image (α : Type) : Type := Location → α

def lift0 (a : α) : Image α := Function.const _ a

def lift1 (f : α → β) : (Image α → Image β) := fun g => f ∘ g

def lift2 (f : α → β → γ) : (Image α → Image β → Image γ) :=
  fun ia ib => fun l => f (ia l) (ib l)

def monochrome (a : α) := lift0 a

-- C = Ca*Aa*(1-Ab) + Cb*Ab
-- https://stackoverflow.com/questions/26317267/rgba-color-mixing-css
def blendRat (c1 c2 alpha1 alpha2 : Rat) : Rat := c1 * alpha1 * (1 - alpha2) + c2 * alpha2

def blend (c1 c2 : Color) : Color :=
  ⟨
    blendRat c1.r c2.r c1.alpha c2.alpha,
    blendRat c1.g c2.g c1.alpha c2.alpha,
    blendRat c1.b c2.b c1.alpha c2.alpha,
    blendRat 1 1 c1.alpha c2.alpha
  ⟩

theorem blendIsAssocociative (c1 c2 c3 : Color) : blend c1 (blend c2 c3) = blend (blend c1 c2) c3 := by
  sorry

def over [BEq α] [Inhabited α] (a1 a2 : α) : α :=
  if a1 == default then a2 else a1

def overi [BEq α] [Inhabited α] (i1 i2 : Image α) : Image α := lift2 over i1 i2

def blendi (i1 i2 : Image Color) : Image Color := lift2 blend i1 i2

def condi (c : Image Bool) (ia1 ia2 : Image α) : Image α :=
  fun l => if c l then ia1 l else ia2 l

def emptyImage : Image Color := monochrome Color.transparent

def crop (c : Image Bool) (im : Image Color) : Image Color := condi c im emptyImage

def transform (f : Location → Location) (i : Image Color) : Image Color := i ∘ f

instance [i : Inhabited α] : Inhabited (Image α) where
  default := monochrome i.default

instance [BEq α] [Inhabited α] [Append α] : Append (Image α) where
  append : Image α → Image α → Image α := overi

instance : Append (Image Color) where
  append : Image Color → Image Color → Image Color := blendi

def render (width height : Nat) (i : Image Color) : IO Unit := do
  for x in [0:width:1] do
    for y in [0:height:1] do
      let p := ⟨x.toFloat, y.toFloat⟩
      let pRat := ⟨x, y⟩
      Raylean.drawPixelV p (toRaylean (i pRat))
