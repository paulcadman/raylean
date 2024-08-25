namespace Rand

structure Generator where
  private stdgen : StdGen

def init (seed: Nat): IO Generator := do
  IO.setRandSeed seed
  let gen: StdGen ← IO.stdGenRef.get
  return ⟨ gen ⟩

def Generator.range (_g: Generator): Nat × Nat :=
  stdRange

def Generator.next (g: Generator): Nat × Generator :=
  let (n, stdgen) := stdNext g.stdgen
  (n, ⟨ stdgen ⟩ )

def Generator.split (g: Generator): (Generator × Generator) :=
  let (stdgen1, stdgen2) := stdSplit g.stdgen
  (⟨ stdgen1 ⟩, ⟨ stdgen2 ⟩)

instance : RandomGen Generator where
  range := Generator.range
  next := Generator.next
  split := Generator.split

end Rand
