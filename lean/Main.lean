import «Raylib»

def renderFrame (doFrame : IO Unit) : IO Unit := do
    beginDrawing
    doFrame
    endDrawing

def doRender : IO Unit := do
  while not (← windowShouldClose) do
    renderFrame do
      drawFPS 100 100
      clearBackground Color.green
      drawText "Hello From Lean!" 190 200 20 Color.black
  closeWindow

def main : IO Unit := do
  initWindow 800 450 "Hello From Lean!"
  setTargetFPS 60
  doRender
