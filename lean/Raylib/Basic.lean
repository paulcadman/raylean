import «Raylib».Types

@[extern "initWindow"]
opaque initWindow : (width : Nat) → (height : Nat) → (title : @& String) → IO Unit

@[extern "getRandomValue"]
opaque getRandomValue : UInt32 → UInt32 → IO UInt32

@[extern "windowShouldClose"]
opaque windowShouldClose : IO Bool

@[extern "closeWindow"]
opaque closeWindow : IO Unit

@[extern "beginDrawing"]
opaque beginDrawing : IO Unit

@[extern "endDrawing"]
opaque endDrawing : IO Unit

@[extern "clearBackground"]
opaque clearBackground : (c : Color) → IO Unit

@[extern "drawText"]
opaque drawText : (text : @& String) → (posX : Nat) → (posY : Nat) → (fontSize : Nat) → (color : Color) → IO Unit

@[extern "drawFPS"]
opaque drawFPS : (posX : Nat) → (posY : Nat) → IO Unit

@[extern "setTargetFPS"]
opaque setTargetFPS : (fps : Nat) → IO Unit

@[extern "drawCircleV"]
opaque drawCircleV : (center : Vector2) → (radius : Float) → (color : Color) → IO Unit

@[extern "isKeyDown"]
opaque isKeyDown : (key : Nat) → IO Bool
