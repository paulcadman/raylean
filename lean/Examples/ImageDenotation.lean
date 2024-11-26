import Raylean

open Raylean
open Raylean.Types

namespace ImageDenotation

def screenWidth := 80
def screenHeight := 60

def main : IO Unit := do
  initWindow screenWidth screenHeight "Image Denotation"
  setTargetFPS 10
  while not (← windowShouldClose) do
    renderFrame do
      Image.render screenWidth screenHeight
        (Image.blendi
          (Image.monochrome Image.bluish)
          (Image.monochrome Image.redish))
      drawFPS 100 100
  closeWindow
