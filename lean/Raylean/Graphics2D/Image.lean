import Raylean
import Batteries

open Raylean.Types

structure Location where
  x : Rat
  y : Rat

def Image (α : Type) : Type := Location → α

def lift0 (a : α) : Image α := Function.const _ a

def lift1 (f : α → β) : (Image α → Image β) := fun g => f ∘ g

def lift2 (f : α → β → γ) : (Image α → Image β → Image γ) :=
  fun ia ib => fun l => f (ia l) (ib l)

def monochrome (a : α) := lift0 a

def blend (a1 a2 : Color) : Color :=
  if a1.a == 0 then a2 else a1

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
