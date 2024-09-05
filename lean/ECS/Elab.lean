import ECS.Basic
import ECS.Store
import ECS.EntityCounter

import Lean

namespace ECS

open Lean Elab Command Term Meta

def toSnd (f : α → β) (a : α) : α × β := (a , f a)

def mapToSnd [Functor f] (g : α → β) : f α → f (α × β) := Functor.map (toSnd g)

def mapMToSnd [Monad m] (g : α → m β) (fa : Array α) : m (Array (α × β)) := do
  let mg (a : α) : m (α × β) := do
    let mb ← g a
    return (a , mb)
  fa.mapM mg

def const (a : α) : β → α := fun _ => a

-- TODO: There should be a way to do this with mkFreshUserName
def mkFreshName (basename : Name) := liftTermElabM <| do
  let freshId ← mkFreshId
  pure <| basename.appendAfter (toString freshId)

def mkFreshIdent (basename : Name) := mkIdent <$> mkFreshName basename

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
  -- identifiers exposed to the caller
  let worldStructName := "World"
  let world := mkIdent <| Name.mkSimple worldStructName
  let initWorld := mkIdent <| Name.mkSimple "initWorld"
  let worldmk := mkIdent <| Name.mkStr2 worldStructName "mk"

  -- resolve the type names of passed idenifiers
  let elemNames := (← elemIdents.mapM Lean.resolveGlobalConstNoOverload)

  -- register all components
  for t in elemNames do
    elabCommand (← `(makeMapComponent $(mkIdent t)))

  -- fresh names for world fields
  let worldNames ← mapMToSnd (const <| mkFreshIdent `world) elemNames
  let worldEntity ← mkFreshIdent `world

  let mut fields ← worldNames.mapM <| fun (n, w) => do
    `(Lean.Parser.Command.structExplicitBinder| ( $w : MapStorage $(mkIdent n) ))
  fields := fields.push (← `(Lean.Parser.Command.structExplicitBinder| ( $worldEntity : GlobalStorage EntityCounter )))

  -- define thw World structure
  elabCommand (← `(
    structure $world where
      $fields:structExplicitBinder*
  ))

  -- register a Has instance for each component
  for (t, w) in worldNames do
    elabCommand (← `(
      instance : @Has $world $(mkIdent t) (MapStorage $(mkIdent t)) _ where
        getStore := (·.$w) <$> read
    ))
  elabCommand (← `(
    instance : @Has $world EntityCounter (GlobalStorage EntityCounter) _ where
      getStore := (·.$worldEntity) <$> read
  ))

  -- fresh names for World.mk constructure arguments
  let storeNames ← mapMToSnd (const <| mkFreshIdent `store) elemNames
  let storeEntity ← mkFreshIdent `store

  let mut storageInitLets := #[]
  for (t, s) in storeNames do
    storageInitLets := storageInitLets.push
      (← `(Lean.Parser.Term.doSeqItem| let $s : MapStorage $(mkIdent t) ← ExplInit.explInit))
  storageInitLets := storageInitLets.push
    (← `(Lean.Parser.Term.doSeqItem| let $storeEntity : GlobalStorage EntityCounter ← ExplInit.explInit))

  let mut worldmkArgs := #[]
  for (_, s) in storeNames do
    worldmkArgs := worldmkArgs.push s
  worldmkArgs := worldmkArgs.push storeEntity

  -- define initWorld
  elabCommand (← `(
    def $initWorld : IO $world := do
      $storageInitLets:doSeqItem*
      return ($worldmk $worldmkArgs*)
))
