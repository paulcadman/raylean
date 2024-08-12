import «Raylib»

namespace Keys

inductive Keys where
  | Down: Keys
  | Up: Keys
  | Left: Keys
  | Right: Keys
  deriving BEq

def getKeys: IO (List Keys) := do
  let mut keys := #[]
  if (← isKeyDown Key.down)
    then keys := keys.push Keys.Down
  if (← isKeyDown Key.up)
    then keys := keys.push Keys.Up
  if (← isKeyDown Key.left)
    then keys := keys.push Keys.Left
  if (← isKeyDown Key.right)
    then keys := keys.push Keys.Right
  return keys.toList

end Keys
