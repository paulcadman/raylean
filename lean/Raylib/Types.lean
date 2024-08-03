structure Vector2 where
  x : Float
  y : Float

structure Vector3 where
  x : Float
  y : Float
  z : Float

inductive CameraProjection where
  | perspective
  | orthographic

structure Camera3D where
  position : Vector3
  target : Vector3
  up : Vector3
  fovy : Float
  projection : CameraProjection

inductive CameraMode where
  | custom
  | free
  | orbital
  | firstPerson
  | thridPerson

structure Color where
  r : UInt8
  g : UInt8
  b : UInt8
  a : UInt8 := 255

namespace Color

def white       := { r:=255, g:=255, b:=255, a:=255 : Color }
def red         := { r:=255, g:=0, b:=0, a:=255 : Color }
def green       := { r:=0, g:=255, b:=0, a:=255 : Color }
def blue        := { r:=0, g:=0, b:=255, a:=255 : Color }
def yellow      := { r:=0, g:=255, b:=255, a:=255 : Color }
def black       := { r:=0, g:=0, b:=0, a:=255 : Color }
def magenta     := { r := 255, g := 0, b := 255, a := 255 : Color  }
def transparent := { r:=0, g:=0, b:=0, a:=0 : Color }

namespace Raylib

def lightgray  := { r := 200, g := 200, b := 200, a := 255 : Color  }
def gray       := { r := 130, g := 130, b := 130, a := 255 : Color  }
def darkgray   := { r := 80, g := 80, b := 80, a := 255 : Color  }
def yellow     := { r := 253, g := 249, b := 0, a := 255 : Color  }
def gold       := { r := 255, g := 203, b := 0, a := 255 : Color  }
def orange     := { r := 255, g := 161, b := 0, a := 255 : Color  }
def pink       := { r := 255, g := 109, b := 194, a := 255 : Color  }
def red        := { r := 230, g := 41, b := 55, a := 255 : Color  }
def maroon     := { r := 190, g := 33, b := 55, a := 255 : Color  }
def green      := { r := 0, g := 228, b := 48, a := 255 : Color  }
def lime       := { r := 0, g := 158, b := 47, a := 255 : Color  }
def darkgreen  := { r := 0, g := 117, b := 44, a := 255 : Color  }
def skyblue    := { r := 102, g := 191, b := 255, a := 255 : Color  }
def blue       := { r := 0, g := 121, b := 241, a := 255 : Color  }
def darkblue   := { r := 0, g := 82, b := 172, a := 255 : Color  }
def purple     := { r := 200, g := 122, b := 255, a := 255 : Color  }
def violet     := { r := 135, g := 60, b := 190, a := 255 : Color  }
def darkpurple := { r := 112, g := 31, b := 126, a := 255 : Color  }
def beige      := { r := 211, g := 176, b := 131, a := 255 : Color  }
def brown      := { r := 127, g := 106, b := 79, a := 255 : Color  }
def darkbrown  := { r := 76, g := 63, b := 47, a := 255 : Color  }
def raywhite   := { r := 245, g := 245, b := 245, a := 255 : Color  }

end Raylib

end Color

namespace Key

def space : Nat := 32
def right : Nat := 262
def left : Nat := 263
def down : Nat := 264
def up : Nat := 265

end Key
