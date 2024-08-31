import ECS.Basic

/-- Run a system in a game world --/
def runSystem (s : System w α) (world : w) : IO α := s.run world

/-- Read a component --/
def get
  [s : StorageT c]
  [Elem (StorageT.storageType c)]
  [comp : Component c]
  [Has w c]
  [e : ExplGet s.storageType]
  (ety : Entity) : System w c := do
    let s  ← Has.getStore
    comp.constraint.mp <$> e.explGet s ety

/-- Writes a component to the given entity. Will overwrite existing components --/
def set
  [s : StorageT c]
  [Elem (StorageT.storageType c)]
  [comp : Component c]
  [Has w c]
  [e : ExplSet s.storageType]
  (ety : Entity)
  (x : c) : System w Unit := do
    let s ← Has.getStore
    e.explSet s ety (comp.constraint.symm.mp x)

/-- Returns whether the given entity has component c --/
def exists?
  (c : Type)
  [s : StorageT c]
  [Elem (StorageT.storageType c)]
  [Component c]
  [Has w c]
  [e : ExplGet s.storageType]
  (ety : Entity) : System w Bool := do
  let s ← Has.getStore
  e.explExists  s ety

/-- Destroys component c for the given enitty --/
def destroy
  (c : Type)
  [s : StorageT c]
  [Elem (StorageT.storageType c)]
  [Component c]
  [Has w c]
  [e : ExplDestroy s.storageType]
  (ety : Entity) : System w Unit := do
  let s ← Has.getStore
  e.explDestroy s ety

/-- Applies a function if the given entity exists in the source component --/
def modify'
  [sa : StorageT cx]
  [Elem (StorageT.storageType cx)]
  [sb : StorageT cy]
  [Elem (StorageT.storageType cy)]
  [compX : Component cx]
  [compY : Component cy]
  [Has w cx]
  [Has w cy]
  [getX : ExplGet sa.storageType]
  [setY : ExplSet sb.storageType]
  (ety : Entity)
  (f : cx → cy) : System w Unit := do
  let sx ← Has.getStore
  let sy ← Has.getStore
  if (← getX.explExists sx ety)
    then do
      let x ← getX.explGet sx ety
      setY.explSet sy ety (compY.constraint.symm.mp (f (compX.constraint.mp x)))

/-- Maps a function over all entities with a cx component and writes their cy --/
def cmap
  [sx : StorageT cx]
  [Elem (StorageT.storageType cx)]
  [sy : StorageT cy]
  [Elem (StorageT.storageType cy)]
  [compX : Component cx]
  [compY : Component cy]
  [Has w cx]
  [Has w cy]
  [getX : ExplGet sx.storageType]
  [setY : ExplSet sy.storageType]
  [mX : ExplMembers sx.storageType]
  (f : cx → cy) : System w Unit := do
  let stx ← Has.getStore
  let sty ← Has.getStore
  let sl ← mX.explMembers stx
  for ety in sl do
    let x ← getX.explGet stx ety
    setY.explSet sty ety (compY.constraint.symm.mp (f (compX.constraint.mp x)))

def cmapM
  [sx : StorageT cx]
  [Elem (StorageT.storageType cx)]
  [sy : StorageT cy]
  [Elem (StorageT.storageType cy)]
  [compX : Component cx]
  [compY : Component cy]
  [Has w cx]
  [Has w cy]
  [getX : ExplGet sx.storageType]
  [setY : ExplSet sy.storageType]
  [mX : ExplMembers sx.storageType]
  (sys : cx → System w cy) : System w Unit := do
  let stx ← Has.getStore
  let sty ← Has.getStore
  let sl ← mX.explMembers stx
  for ety in sl do
    let x ← getX.explGet stx ety
    let fx ← sys (compX.constraint.mp x)
    setY.explSet sty ety (compY.constraint.symm.mp fx)

def cmapM_
  [sx : StorageT cx]
  [Elem (StorageT.storageType cx)]
  [compX : Component cx]
  [Has w cx]
  [getX : ExplGet sx.storageType]
  [mX : ExplMembers sx.storageType]
  (sys : cx → System w Unit) : System w Unit := do
  let stx ← Has.getStore
  let sl ← mX.explMembers stx
  for ety in sl do
    let x ← getX.explGet stx ety
    sys (compX.constraint.mp x)
