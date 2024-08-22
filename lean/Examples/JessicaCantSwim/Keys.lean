import «Raylib»

namespace Keys

inductive Keys where
  | Down: Keys
  | Up: Keys
  | Left: Keys
  | Right: Keys
  deriving BEq

end Keys
