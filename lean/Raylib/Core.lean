import «Raylib».Types

/- Window-related functions -/

@[extern "initWindow"]
opaque initWindow : (width : Nat) → (height : Nat) → (title : @& String) → IO Unit

@[extern "closeWindow"]
opaque closeWindow : IO Unit

@[extern "windowShouldClose"]
opaque windowShouldClose : IO Bool

/- Cursor-related functions -/

@[extern "disableCursor"]
opaque disableCursor : IO Unit

/- Drawing-related functions -/

@[extern "clearBackground"]
opaque clearBackground : (c : Color) → IO Unit

@[extern "beginDrawing"]
opaque beginDrawing : IO Unit

@[extern "endDrawing"]
opaque endDrawing : IO Unit

@[extern "beginMode2D"]
opaque beginMode2D : (camera : Camera2D) → IO Unit

@[extern "endMode2D"]
opaque endMode2D : IO Unit

@[extern "beginMode3D"]
opaque beginMode3D : (camera : Camera3D) → IO Unit

@[extern "endMode3D"]
opaque endMode3D : IO Unit

/- Timing-related functions -/

@[extern "setTargetFPS"]
opaque setTargetFPS : (fps : Nat) → IO Unit

@[extern "getFrameTime"]
opaque getFrameTime : IO Float

/- Random values generation functions -/

@[extern "getRandomValue"]
opaque getRandomValue : UInt32 → UInt32 → IO UInt32

/- Input-related functions: keyboard -/

@[extern "isKeyDown"]
opaque isKeyDown : (key : Nat) → IO Bool

/- Camera System Functions -/

@[extern "updateCamera"]
opaque updateCamera : (camera : Camera3D) → (mode : CameraMode) → IO Camera3D

/- Basic shapes drawing functions -/

@[extern "drawCircleV"]
opaque drawCircleV : (center : Vector2) → (radius : Float) → (color : Color) → IO Unit

@[extern "drawRectangleRec"]
opaque drawRectangleRec : (rectangle : Rectangle) → (color : Color) → IO Unit

/- Screen-space-related functions -/

/-- Get the world space position for a 2d camera screen space position -/
@[extern "getScreenToWorld2D"]
opaque getScreenToWorld2D : (position : Vector2) → (camera : Camera2D) → Vector2

/- Text drawing functions -/

@[extern "drawFPS"]
opaque drawFPS : (posX : Nat) → (posY : Nat) → IO Unit

@[extern "drawText"]
opaque drawText : (text : @& String) → (posX : Nat) → (posY : Nat) → (fontSize : Nat) → (color : Color) → IO Unit

/- Basic geometric 3D shapes drawing functions -/

@[extern "drawCube"]
opaque drawCube : (position : Vector3) → (width : Float) → (height : Float) → (length : Float) → (color : Color) -> IO Unit

@[extern "drawCubeWires"]
opaque drawCubeWires : (position : Vector3) → (width : Float) → (height : Float) → (length : Float) → (color : Color) -> IO Unit

@[extern "drawGrid"]
opaque drawGrid : (slices : Nat) → (spacing : Float) → IO Unit
