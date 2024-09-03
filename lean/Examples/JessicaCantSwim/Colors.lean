namespace Colors

structure Color where
  /-- Color red value -/
  r : UInt8
  /-- Color green value -/
  g : UInt8
  /-- Color blue value -/
  b : UInt8
  /-- Color alpha value -/
  a : UInt8 := 255
  deriving BEq

def white       := { r:=255, g:=255, b:=255, a:=255 : Color }
def red         := { r:=255, g:=0, b:=0, a:=255 : Color }
def green       := { r:=0, g:=255, b:=0, a:=255 : Color }
def blue        := { r:=0, g:=0, b:=255, a:=255 : Color }
def yellow      := { r:=0, g:=255, b:=255, a:=255 : Color }
def black       := { r:=0, g:=0, b:=0, a:=255 : Color }
def magenta     := { r := 255, g := 0, b := 255, a := 255 : Color  }
def transparent := { r:=0, g:=0, b:=0, a:=0 : Color }

end Colors
