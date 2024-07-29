import «LeanChess»

@[extern "InitWindow"]
opaque initWindow : UInt32 → UInt32 -> String -> IO Unit

@[extern "GetRandomValue"]
opaque getRandomValue : UInt32 -> UInt32 -> UInt32

@[extern "my_add"]
opaque myAdd : UInt32 → UInt32 → UInt32

def main : IO Unit := do
  IO.println s!"Hello, {hello}!"
  let width := UInt32.mk 100
  let height := UInt32.mk 1000
  let r : UInt32 := getRandomValue width height
  let x : UInt32 := myAdd (1 : UInt32) (2 : UInt32)
  IO.println s!"Hello {r} {x}"
  -- initWindow 800 600 "abc"
