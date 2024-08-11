import Lens.Basic

import Lean

namespace Elab

/-
makeLenses T` creates a lens for each field of the structure `T`.
The name of the lens is the same as the corresponding projection function.
The lenses are declared in the namespace T.Lens.
-/
open Lean Elab Command Term Meta in
elab "makeLenses" structIdent:ident : command => do
  let name ← resolveGlobalConstNoOverload structIdent
  let env ← getEnv
  let some info := getStructureInfo? env name
    | throwErrorAt structIdent "Not a structure"
  let mut defs : Array Syntax := #[]
  let lensNs := mkIdent <| structIdent.raw.getId ++ Name.mkSimple "Lens"
  for field in info.fieldInfo do
    let fieldNameIdent := mkIdent field.fieldName
    let some decl := env.find? (field.projFn)
      | throwErrorAt structIdent s!"Could not find project function {field.projFn}"
    let (some fieldTypeName, some fieldTypeArgs) := (← liftTermElabM (liftMetaM (
             forallTelescope decl.type fun _ body
               => pure (body.getAppFn.constName?, body.getAppArgs.mapM (·.constName?)))))
      | throwErrorAt structIdent "Not a structure name"
    let d ← fieldTypeArgs.mapM fun argName => `($(mkIdent argName))
    let fieldTypeNameIdent := Syntax.mkCApp fieldTypeName d
    let lensName := mkIdent field.fieldName
    let newVal := mkIdent <| Name.mkSimple "newVal"
    let l ←
      `(fun {f} [Functor f] g p =>
        Functor.map
          (fun $newVal =>
            { p with $fieldNameIdent:ident := $newVal})
            (g p.$fieldNameIdent:ident))
    defs := defs.push
      (← `(def $lensName : @Lens $(mkIdent name) $(mkIdent name) $fieldTypeNameIdent $fieldTypeNameIdent := $l))
  elabCommand (← `(namespace $lensNs))
  for d in defs do
    elabCommand d
  elabCommand (← `(end $lensNs))

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

structure Group where
  people : List Person'

makeLenses Name'
makeLenses Person'
makeLenses Group

open Person'.Lens
open Name'.Lens
open Group.Lens

def exampleView' : IO Unit :=
  let person : Person' := { name := {firstname := "Alice", surname := "H"}, age := 30 }
  let personName := person ^. name ∘ firstname
  IO.println s!"Name: {personName}"

def exampleSet' : IO Unit :=
  let person := { name := { firstname := "Alice", surname := "H"}, age := 30 }
  let updatedPerson := set (name ∘ firstname) "Bob" person
  IO.println s!"Updated name: {updatedPerson.name.firstname}"

def exampleOver' : IO Unit :=
  let person := { name := {firstname := "Alice", surname := "H"} , age := 30 }
  let updatedPerson := over (name ∘ firstname) (String.append · "zzzSmith") person
  IO.println s!"Modified name: {updatedPerson.name.firstname}"

end Example
