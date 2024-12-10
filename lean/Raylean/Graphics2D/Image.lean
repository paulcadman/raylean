import Raylean.Types
import Raylean.Core
import Batteries
import Mathlib.Tactic.Linarith

namespace Raylean.Image

class LawfulMonoid (α : Type _) [Append α] [Inhabited α]: Prop where
  assoc {x y z : α} : (x ++ (y ++ z)) = ((x ++ y) ++ z)
  left_id {x: α} : default ++ x = x
  right_id {x: α} : x ++ default = x

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

def Image (α : Type u) : Type u := Location → α

def lift0 (a : α) : Image α := Function.const _ a

def lift1 (f : α → β) : (Image α → Image β) := fun g => f ∘ g

def lift2 (f : α → β → γ) : (Image α → Image β → Image γ) :=
  fun ia ib => fun l => f (ia l) (ib l)

def Image.monochrome (a : α): Image α := lift0 a

-- sover or source-over blends two colors.
def Color.sover (c1 c2 : Color) : Color :=
  -- Result = Source + Desitination × (1 − Source_alpha)
  -- https://ciechanow.ski/alpha-compositing/#compositing-done-right
  let sover' (src dst alpha : Rat) : Rat := src + dst - dst * alpha
  ⟨
    sover' c1.r c2.r c1.alpha,
    sover' c1.g c2.g c1.alpha,
    sover' c1.b c2.b c1.alpha,
    sover' c1.alpha c2.alpha c1.alpha
  ⟩

example (h : ∀ i : ℕ, i < 7 → ∃ j, i < j ∧ j < i+i) : True := by
  choose! f h h' using h
  guard_hyp f : ℕ → ℕ
  guard_hyp h : ∀ (i : ℕ), i < 7 → i < f i
  guard_hyp h' : ∀ (i : ℕ), i < 7 → f i < i + i
  trivial

theorem color_sover_assoc (x y z: Color):
  Color.sover x (Color.sover y z)
  = Color.sover (Color.sover x y) z := by
  unfold Color.sover
  simp
  split_ands
  guard_goal_nums 4
  · linarith
  · linarith
  · linarith
  · linarith

theorem color_left_id {x: Color}: Color.sover Color.transparent x = x := by
  unfold Color.transparent
  unfold Color.sover
  simp

theorem color_right_id {x: Color}: Color.sover x Color.transparent = x := by
  unfold Color.transparent
  unfold Color.sover
  simp

instance : Inhabited Color where
  default := Color.transparent

instance : Append Color where
  append : Color → Color → Color := Color.sover

theorem color_append_assoc {x y z: Color}:
  x ++ (y ++ z)
  = (x ++ y) ++ z := by
  apply color_sover_assoc

instance : LawfulMonoid Color where
  assoc := color_append_assoc
  left_id := color_left_id
  right_id := color_right_id

def over [BEq α] [Inhabited α] (a1 a2 : α) : α :=
  if a1 == default then a2 else a1

def overi [BEq α] [Inhabited α] (i1 i2 : Image α) : Image α := lift2 over i1 i2

def Image.sover (i1 i2 : Image Color) : Image Color := lift2 Color.sover i1 i2

def condi (c : Image Bool) (ia1 ia2 : Image α) : Image α :=
  fun l => if c l then ia1 l else ia2 l

def Image.transparent : Image Color := Image.monochrome Color.transparent

def crop (c : Image Bool) (im : Image Color) : Image Color := condi c im Image.transparent

def transform (f : Location → Location) (i : Image Color) : Image Color := i ∘ f

instance [i : Inhabited α] : Inhabited (Image α) where
  default := Image.monochrome i.default

instance [BEq α] [Inhabited α] [Append α] : Append (Image α) where
  append : Image α → Image α → Image α := overi

instance : Append (Image Color) where
  append : Image Color → Image Color → Image Color := Image.sover

theorem image_color_assoc {x y z: Image Color}:
  (Image.sover x (Image.sover y z))
  = (Image.sover (Image.sover x y) z) := by
  unfold Image.sover
  unfold lift2
  funext l
  rw [color_sover_assoc]

theorem image_color_append_assoc {x y z: Image Color}: (x ++ (y ++ z)) = ((x ++ y) ++ z) := by
  apply image_color_assoc

theorem image_color_left_id {x: Image Color}: default ++ x = x := by
  unfold_projs
  unfold Image.monochrome
  unfold lift0
  unfold Function.const
  unfold Image.sover
  unfold lift2
  funext l
  rw [color_left_id]

theorem image_color_right_id {x: Image Color}: x ++ default = x := by
  unfold_projs
  unfold Image.monochrome
  unfold lift0
  unfold Function.const
  unfold Image.sover
  unfold lift2
  funext l
  rw [color_right_id]

instance : LawfulMonoid (Image Color) where
  assoc := image_color_append_assoc
  left_id := image_color_left_id
  right_id := image_color_right_id

def Image.map {α β : Type u} (f: α → β) (i: Image α): Image β :=
  fun l => f (i l)

instance : Functor Image where
  map := Image.map

theorem image_id_map {α: Type u} (x : Image α) : id <$> x = x := by
  guard_target = id <$> x = x
  unfold_projs
  guard_target = Image.map id x = x
  unfold Image.map
  guard_target = (fun l => id (x l)) = x
  simp

theorem image_map_const:
  (Functor.mapConst : α → Image β → Image α)
  = Functor.map ∘ Function.const β := by
  unfold_projs
  unfold Image.map
  simp

theorem image_comp_map (g : α → β) (h : β → γ) (x : Image α):
  (h ∘ g) <$> x = h <$> g <$> x := by
  unfold_projs
  guard_target = Image.map (h ∘ g) x = Image.map h (Image.map g x)
  unfold Image.map
  guard_target = (fun l => (h ∘ g) (x l)) = fun l => h (g (x l))
  simp

-- #find [] ++ ?x = ?x
-- #loogle [] ++ ?x = ?x

#help tactic

instance : LawfulFunctor Image where
  map_const := image_map_const
  id_map := image_id_map
  comp_map := image_comp_map

def render (width height : Nat) (i : Image Color) : IO Unit := do
  for x in [0:width:1] do
    for y in [0:height:1] do
      let p := ⟨x.toFloat, y.toFloat⟩
      let pRat := ⟨x, y⟩
      Raylean.drawPixelV p (toRaylean (i pRat))
