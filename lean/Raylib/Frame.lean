import «Raylib».Basic

def renderFrame (mkFrame : IO Unit) : IO Unit := do
    beginDrawing
    mkFrame
    endDrawing
