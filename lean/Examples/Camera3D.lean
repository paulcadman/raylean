import «Raylib»

private def screenWidth : Nat := 800
private def screenHeight : Nat := 450
private def fps : Nat := 120

private def cubePosition : Vector3 := { x := 0, y := 0, z := 0 : Vector3 }

private def doRender : IO Unit := do
  let mut camera : Camera3D := {
    position := { x := 10, y := 10, z := 10 },
    target := { x := 0, y := 0, z := 0 },
    up := { x := 0, y := 1, z := 0 },
    fovy := 45,
    projection := CameraProjection.perspective
  }
  disableCursor
  while not (← windowShouldClose) do
    camera <- updateCamera camera CameraMode.free
    if (<- isKeyDown Key.space) then
      camera := { camera with target := cubePosition }
    renderFrame do
      clearBackground Color.white
      beginMode3D camera
      drawCube cubePosition 2 2 2 Color.red
      drawCubeWires cubePosition 2 2 2 Color.blue
      drawGrid 10 1
      endMode3D
      drawFPS (screenWidth - 100) 10
      drawText "Welcome to the third dimension" 10 40 20 Color.black

def camera3D : IO Unit := do
  initWindow screenWidth screenHeight "Camera3D"
  setTargetFPS fps
  doRender
