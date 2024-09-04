import ECS.Basic
import ECS.Store
import ECS.EntityCounter

import Lean

namespace ECS

open Lean Elab Command Term Meta

elab "makeMapComponent" elemIdent:ident : command => do
  let elemName ← Lean.resolveGlobalConstNoOverload elemIdent
  let axiomName : Ident ← liftCoreM (mkIdent <$> (mkFreshUserName (Name.mkSimple s!"Storage{elemIdent.getId}")))
  elabCommand (← `(axiom $axiomName : StorageFam $(mkIdent elemName) = MapStorage $(mkIdent elemName)))
  elabCommand (← `(instance : FamilyDef StorageFam $(mkIdent elemName) (MapStorage $(mkIdent elemName)) := ⟨$axiomName⟩))
  elabCommand (← `(
    instance : @Component $(mkIdent elemName) (MapStorage $(mkIdent elemName)) $(mkIdent elemName) _ _ where
      constraint := rfl
  ))

elab "makeMapComponents" elemIdents:ident* : command => do
  for t in (← elemIdents.mapM Lean.resolveGlobalConstNoOverload) do
    elabCommand (← `(makeMapComponent $(mkIdent t)))

elab "makeWorldAndComponents" elemIdents:ident* : command => do
  let worldStructName := "World"
  let elemNames := (← elemIdents.mapM Lean.resolveGlobalConstNoOverload)
  for t in elemNames do
    elabCommand (← `(makeMapComponent $(mkIdent t)))

  let mkWorldName (e : Ident) : Name := Name.mkSimple s!"world{e.getId}"
 
  let mut fields ← elemIdents.mapM <| fun e => do
    let fname := mkWorldName e
    let n ← Lean.resolveGlobalConstNoOverload e
    `(Lean.Parser.Command.structExplicitBinder| ( $(mkIdent fname) : MapStorage $(mkIdent n) ))

  let worldEntity := mkIdent <| Name.mkSimple "worldEntity"
  fields := fields.push (← `(Lean.Parser.Command.structExplicitBinder| ( $worldEntity : GlobalStorage EntityCounter )))

  let world := mkIdent <| Name.mkSimple worldStructName

  elabCommand (← `(
    structure $world where
      $fields:structExplicitBinder*
  ))

  for t in elemNames do
    elabCommand (← `(
      instance : @Has $world $(mkIdent t) (MapStorage $(mkIdent t)) _ where
        getStore := (·.$(mkIdent <| mkWorldName <| mkIdent t)) <$> read
    ))

  elabCommand (← `(
    instance : @Has $world EntityCounter (GlobalStorage EntityCounter) _ where
      getStore := (·.$worldEntity) <$> read
  ))

  let initWorld := mkIdent <| Name.mkSimple "initWorld"

  let mkStorageName (n : Name) : Name := Name.mkSimple s!"store{n.getString!}"
  let entityStorageName : Name := Name.mkSimple "storeEntity"

  let mut initBinders := #[]
  for t in elemNames do
    initBinders := initBinders.push (← `(Lean.Parser.Term.doSeqItem| let $(mkIdent <| mkStorageName t) : MapStorage $(mkIdent t) ← ExplInit.explInit))
  initBinders := initBinders.push (← `(Lean.Parser.Term.doSeqItem| let $(mkIdent entityStorageName) : GlobalStorage EntityCounter ← ExplInit.explInit))

  let mut args := #[]
  for t in elemNames do
    args := args.push (mkIdent <| mkStorageName t)
  args := args.push (mkIdent entityStorageName)
  let worldmk := mkCIdent <| Name.mkStr2 worldStructName "mk"

  elabCommand (← `(
    def $initWorld : IO $world := do
      $initBinders:doSeqItem*
      return ($worldmk $args*)
))
