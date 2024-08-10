import Lens.Const
open Const

def Lens (s t a b : Type) :=
  ∀ {f : Type → Type} [Functor f], (a → f b) → s → f t

def view {s a : Type} (l : Lens s s a a) (x : s) : a :=
  (l (fun y => (y : Const a a)) x : Const a s)

def set {s t a b : Type} (l : Lens s t a b) (y : b) (x : s) : t :=
  (l (fun _ => y) x : Id t)

def over {s t a b : Type} (l : Lens s t a b) (f : a → b) (x : s) : t :=
  (l (fun a => f a) x : Id t)

infixl:50 " ^. " => flip view

namespace Example

structure Name where
  firstname : String
  surname : String

structure Person where
  name : Name
  age : Nat

namespace Lens

def firstname : Lens Name Name String String :=
  fun {f} [Functor f] g p =>
    Functor.map (fun newFirstName => { p with firstname := newFirstName }) (g p.firstname)

def name : Lens Person Person Name Name :=
  fun {f} [Functor f] g p =>
    Functor.map (fun newName => { p with name := newName }) (g p.name)

end Lens

open Lens

def exampleView : IO Unit :=
  let person : Person := { name := {firstname := "Alice", surname := "H"}, age := 30 }
  let personName := person ^. name ∘ firstname
  IO.println s!"Name: {personName}"

def exampleSet : IO Unit :=
  let person := { name := { firstname := "Alice", surname := "H"}, age := 30 }
  let updatedPerson := set (name ∘ firstname) "Bob" person
  IO.println s!"Updated name: {updatedPerson.name.firstname}"

def exampleOver : IO Unit :=
  let person := { name := {firstname := "Alice", surname := "H"} , age := 30 }
  let updatedPerson := over (name ∘ firstname) (String.append · "zzzSmith") person
  IO.println s!"Modified name: {updatedPerson.name.firstname}"

end Example
