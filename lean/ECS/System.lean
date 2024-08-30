import ECS.Basic

/-- Run a system in a game world --/
def runSystem (s : System w α) (world : w) : IO α := s.run world

/-- Read a component --/
def get
  [comp : Component c]
  [Has w c]
  [e : @ExplGet comp.StorageType comp.elemInstance]
  (ety : Entity) : System w c := do
    let s : comp.StorageType ← Has.getStore
    comp.constraint.mp <$> @ExplGet.explGet _ comp.elemInstance e s ety

/-- Writes a component to the given entity. Will overwrite existing components --/
def set
  [comp : Component c]
  [Has w c]
  [e : @ExplSet comp.StorageType comp.elemInstance]
  (ety : Entity)
  (x : c) : System w Unit := do
    let s : comp.StorageType ← Has.getStore
    @ExplSet.explSet _ comp.elemInstance e s ety (comp.constraint.symm.mp x)

/-- Returns whether the given entity has component c --/
def exists?
  (c : Type)
  [comp : Component c]
  [Has w c]
  [e : @ExplGet comp.StorageType comp.elemInstance]
  (ety : Entity) : System w Bool := do
  let s : comp.StorageType ← Has.getStore
  @ExplGet.explExists _ comp.elemInstance e s ety

/-- Destroys component c for the given enitty --/
def destroy
  (c : Type)
  [comp : Component c]
  [Has w c]
  [e : @ExplDestroy comp.StorageType]
  (ety : Entity) : System w Unit := do
  let s : comp.StorageType ← Has.getStore
  e.explDestroy s ety

/-- Applies a function if the given entity exists in the source component --/
def modify'
  [compX : Component cx]
  [compY : Component cy]
  [Has w cx]
  [Has w cy]
  [getX : @ExplGet compX.StorageType compX.elemInstance]
  [setY : @ExplSet compY.StorageType compY.elemInstance]
  (ety : Entity)
  (f : cx → cy) : System w Unit := do
  let sx : compX.StorageType ← Has.getStore
  let sy : compY.StorageType ← Has.getStore
  if (← @ExplGet.explExists _ compX.elemInstance getX sx ety)
    then do
      let x ← @ExplGet.explGet _ compX.elemInstance getX sx ety
      @ExplSet.explSet _ compY.elemInstance setY sy ety (compY.constraint.symm.mp (f (compX.constraint.mp x)))

/-- Maps a function over all entities with a cx component and writes their cy --/
def cmap
  [compX : Component cx]
  [compY : Component cy]
  [Has w cx]
  [Has w cy]
  [getX : @ExplGet compX.StorageType compX.elemInstance]
  [setY : @ExplSet compY.StorageType compY.elemInstance]
  [mX : @ExplMembers compX.StorageType]
  (f : cx → cy) : System w Unit := do
  let sx : compX.StorageType ← Has.getStore
  let sy : compY.StorageType ← Has.getStore
  let sl ← mX.explMembers sx
  for ety in sl do
    let x ← @ExplGet.explGet _ compX.elemInstance getX sx ety
    @ExplSet.explSet _ compY.elemInstance setY sy ety (compY.constraint.symm.mp (f (compX.constraint.mp x)))

def cmapM
  [compX : Component cx]
  [compY : Component cy]
  [Has w cx]
  [Has w cy]
  [getX : @ExplGet compX.StorageType compX.elemInstance]
  [setY : @ExplSet compY.StorageType compY.elemInstance]
  [mX : @ExplMembers compX.StorageType]
  (sys : cx → System w cy) : System w Unit := do
  let sx : compX.StorageType ← Has.getStore
  let sy : compY.StorageType ← Has.getStore
  let sl ← mX.explMembers sx
  for ety in sl do
    let x ← @ExplGet.explGet _ compX.elemInstance getX sx ety
    let fx ← sys (compX.constraint.mp x)
    @ExplSet.explSet _ compY.elemInstance setY sy ety (compY.constraint.symm.mp fx)
