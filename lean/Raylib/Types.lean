structure Vector2 where
  x : Float
  y : Float

structure Vector3 where
  x : Float
  y : Float
  z : Float

inductive CameraProjection where
  | perspective : CameraProjection
  | orthographic : CameraProjection

structure Camera3D where
  position : Vector3
  target : Vector3
  up : Vector3
  fovy : Float
  projection : CameraProjection

inductive CameraMode where
  | custom : CameraMode
  | free : CameraMode
  | orbital : CameraMode
  | firstPerson : CameraMode
  | thridPerson : CameraMode

structure Color where
  r : UInt8
  g : UInt8
  b : UInt8
  a : UInt8 := 255
  deriving Repr, Inhabited

namespace Color

def white  := { r:=255, g:=255, b:=255, a:=255 : Color }
def red  := { r:=255, g:=0, b:=0, a:=255 : Color }
def green  := { r:=0, g:=255, b:=0, a:=255 : Color }
def blue  := { r:=0, g:=0, b:=255, a:=255 : Color }
def yellow  := { r:=0, g:=255, b:=255, a:=255 : Color }
def black  := { r:=0, g:=0, b:=0, a:=255 : Color }
def transparent  := { r:=0, g:=0, b:=0, a:=0 : Color }

end Color

namespace Key

def space : Nat := 32
def right : Nat := 262
def left : Nat := 263
def down : Nat := 264
def up : Nat := 265

end Key
