import ECS.Basic
import ECS.Store

import Lean

namespace ECS

open Lean Elab Command Term Meta in
elab "makeMapComponent" elemIdent:ident : command => do
  let elemName ← Lean.resolveGlobalConstNoOverload elemIdent
  let axiomName := mkIdent <| Name.mkSimple s!"Storage{elemIdent}"
  elabCommand (← `(axiom $axiomName : StorageFam $(mkIdent elemName) = MapStorage $(mkIdent elemName)))
  elabCommand (← `(instance : FamilyDef StorageFam $(mkIdent elemName) (MapStorage $(mkIdent elemName)) := ⟨$axiomName⟩))
  elabCommand (← `(
    instance : @Component $(mkIdent elemName) (MapStorage $(mkIdent elemName)) $(mkIdent elemName) _ _ where
      constraint := rfl
  ))
