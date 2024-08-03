import «Raylib».Core

def renderFrame (mkFrame : IO Unit) : IO Unit := do
    beginDrawing
    mkFrame
    endDrawing

def renderWithCamera (camera : Camera3D) (mkScene : IO Unit) : IO Unit := do
  beginMode3D camera
  mkScene
  endMode3D
