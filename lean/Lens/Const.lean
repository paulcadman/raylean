def Const (m : Type u) (_α : Type v) : Type u := m

namespace Const

@[always_inline]
instance {m : Type u} : Functor (Const m) where
  map _ x := x

@[always_inline, inline]
def run (x : Const m α) : m := x

end Const
