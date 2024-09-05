import ECS.Basic

namespace ECS

/-- Run a system in a game world --/
def runSystem (s : System w α) (world : w) : IO α := s.run world

/-- Read a component --/
def get
  [FamilyDef StorageFam c s]
  [FamilyDef ElemFam s t]
  [comp : @Component c s t _ _]
  [@Has w c s _]
  [e : @ExplGet s t _]
  (ety : Entity) : System w c := do
    let s ← Has.getStore c
    comp.constraint.mp <$> e.explGet s ety

/-- Writes a component to the given entity. Will overwrite existing components --/
def set'
  {c s t : Type}
  [FamilyDef StorageFam c s]
  [FamilyDef ElemFam s t]
  [comp : @Component c s t _ _]
  [@Has w c s _]
  [e : @ExplSet s t _]
  (ety : Entity)
  (x : c) : System w Unit := do
    let s ← Has.getStore c
    e.explSet s ety (comp.constraint.symm.mp x)

/-- Returns whether the given entity has component c --/
def exists?
  (c : Type)
  [FamilyDef StorageFam c s]
  [FamilyDef ElemFam s t]
  [@Component c s t _ _]
  [@Has w c s _]
  [e : @ExplGet s t _]
  (ety : Entity) : System w Bool := do
  let s ← Has.getStore c
  e.explExists  s ety

/-- Destroys component c for the given enitty --/
def destroy
  (c : Type)
  [FamilyDef StorageFam c s]
  [FamilyDef ElemFam s t]
  [@Component c s t _ _]
  [@Has w c s _]
  [e : ExplDestroy s]
  (ety : Entity) : System w Unit := do
  let s ← Has.getStore c
  e.explDestroy s ety

/-- Applies a function if the given entity exists in the source component --/
def modify'
  [FamilyDef StorageFam cx sx]
  [FamilyDef ElemFam sx tx]
  [FamilyDef StorageFam cy sy]
  [FamilyDef ElemFam sy ty]
  [compX : @Component cx sx tx _ _]
  [compY : @Component cy sy ty _ _]
  [@Has w cx sx _]
  [@Has w cy sy _]
  [getX : @ExplGet sx tx _]
  [setY : @ExplSet sy ty _]
  (ety : Entity)
  (f : cx → cy) : System w Unit := do
  let sx ← Has.getStore cx
  let sy ← Has.getStore cy
  if (← getX.explExists sx ety)
    then do
      let x ← getX.explGet sx ety
      setY.explSet sy ety (compY.constraint.symm.mp (f (compX.constraint.mp x)))

/-- Maps a function over all entities with a cx component and writes their cy --/
def cmap
  [FamilyDef StorageFam cx sx]
  [FamilyDef ElemFam sx tx]
  [FamilyDef StorageFam cy sy]
  [FamilyDef ElemFam sy ty]
  [compX : @Component cx sx tx _ _]
  [compY : @Component cy sy ty _ _]
  [@Has w cx sx _]
  [@Has w cy sy _]
  [getX : @ExplGet sx tx _]
  [setY : @ExplSet sy ty _]
  [mX : ExplMembers sx]
  (f : cx → cy) : System w Unit := do
  let stx ← Has.getStore cx
  let sty ← Has.getStore cy
  let sl ← mX.explMembers stx
  for ety in sl do
    let x ← getX.explGet stx ety
    setY.explSet sty ety (compY.constraint.symm.mp (f (compX.constraint.mp x)))

def cmapM
  [FamilyDef StorageFam cx sx]
  [FamilyDef ElemFam sx tx]
  [FamilyDef StorageFam cy sy]
  [FamilyDef ElemFam sy ty]
  [compX : @Component cx sx tx _ _]
  [compY : @Component cy sy ty _ _]
  [@Has w cx sx _]
  [@Has w cy sy _]
  [getX : @ExplGet sx tx _]
  [setY : @ExplSet sy ty _]
  [mX : ExplMembers sx]
  (sys : cx → System w cy) : System w Unit := do
  let stx ← Has.getStore cx
  let sty ← Has.getStore cy
  let sl ← mX.explMembers stx
  for ety in sl do
    let x ← getX.explGet stx ety
    let fx ← sys (compX.constraint.mp x)
    setY.explSet sty ety (compY.constraint.symm.mp fx)

def cmapM_
  [FamilyDef StorageFam cx sx]
  [FamilyDef ElemFam sx tx]
  [compX : @Component cx sx tx _ _]
  [@Has w cx sx _]
  [getX : @ExplGet sx tx _]
  [mX : ExplMembers sx]
  (sys : cx → System w Unit) : System w Unit := do
  let stx ← Has.getStore cx
  let sl ← mX.explMembers stx
  for ety in sl do
    let x ← getX.explGet stx ety
    sys (compX.constraint.mp x)
