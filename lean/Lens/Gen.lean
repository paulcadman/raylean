import Lens.Basic

import Lean

namespace Elab

open Lean Elab Command Term Meta in
elab "makeLenses" structIdent:ident : command => do
  let name ← resolveGlobalConstNoOverload structIdent
  let env ← getEnv
  let some info := getStructureInfo? env name
    | throwErrorAt structIdent "Not a structure"
  for field in info.fieldInfo do
    let fieldNameIdent := mkIdent field.fieldName
    let some decl := env.find? (field.projFn)
      | throwErrorAt structIdent s!"Could not find project function {field.projFn}"
    let some fieldTypeName := (← liftTermElabM (liftMetaM (forallTelescope decl.type fun _ body => pure body.getAppFn.constName?)))
      | throwErrorAt structIdent "Not a structure name"
    let fieldTypeNameIdent := mkIdent fieldTypeName
    let lensName := mkIdent <| structIdent.raw.getId ++ Name.mkSimple "lens" ++ field.fieldName
    let newVal := mkIdent <| Name.mkSimple "newVal"
    let l ←
      `(fun {f} [Functor f] g p =>
        Functor.map
          (fun $newVal =>
            { p with $fieldNameIdent:ident := $newVal})
            (g p.$fieldNameIdent:ident))
    let defn ←
      `(def $lensName : @Lens $(mkIdent name) $(mkIdent name) $fieldTypeNameIdent $fieldTypeNameIdent := $l)
    elabCommand <| defn

end Elab

namespace Example

structure P where
  name : Nat

makeLenses P

structure Name' where
  firstname : String
  surname : String

structure Person' where
  name : Name'
  age : Nat

makeLenses Name'
makeLenses Person'

def exampleView' : IO Unit :=
  let person : Person' := { name := {firstname := "Alice", surname := "H"}, age := 30 }
  let personName := person ^. Person'.lens.name ∘ Name'.lens.firstname
  IO.println s!"Name: {personName}"

def exampleSet' : IO Unit :=
  let person := { name := { firstname := "Alice", surname := "H"}, age := 30 }
  let updatedPerson := set (Person'.lens.name ∘ Name'.lens.firstname) "Bob" person
  IO.println s!"Updated name: {updatedPerson.name.firstname}"

def exampleOver' : IO Unit :=
  let person := { name := {firstname := "Alice", surname := "H"} , age := 30 }
  let updatedPerson := over (Person'.lens.name ∘ Name'.lens.firstname) (String.append · "zzzSmith") person
  IO.println s!"Modified name: {updatedPerson.name.firstname}"

end Example
