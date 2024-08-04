import Raylib.Types

structure Player where
  position : Vector2
  speed : Float
  canJump : Bool

structure EnvItem where
  rect : Rectangle
  blocking : Bool
  color : Color

structure GameState where
  player : Player
  camera : Camera2D

structure GameEnv where
  items : List EnvItem

def modifyPlayer [MonadState GameState m] (f : Player → Player) : m Unit :=
  modify (fun s => { s with player := f s.player })

def modifyPosition [MonadState GameState m] (f : Vector2 → Vector2) : m Unit :=
  modifyPlayer (fun p => { p with position := f p.position })

def modifyPositionX [MonadState GameState m] (f : Float → Float) : m Unit :=
  modifyPosition (fun v => { v with x := f v.x })

def modifyPositionY [MonadState GameState m] (f : Float → Float) : m Unit :=
  modifyPosition (fun v => { v with y := f v.y })

def modifySpeed [MonadState GameState m] (f : Float → Float) : m Unit :=
  modifyPlayer (fun p => { p with speed := f p.speed })

def setPosition [MonadState GameState m] (p : Vector2) : m Unit :=
  modifyPosition (fun _ => p)

def setPositionX [MonadState GameState m] (px : Float) : m Unit :=
  modifyPositionX (fun _ => px)

def setPositionY [MonadState GameState m] (py : Float) : m Unit :=
  modifyPositionY (fun _ => py)

def setCanJump [MonadState GameState m] (b : Bool) : m Unit :=
  modifyPlayer (fun p => { p with canJump := b })

def setSpeed [MonadState GameState m] (s : Float) : m Unit :=
  modifyPlayer (fun p => { p with speed := s })

abbrev GameM : Type -> Type := StateT GameState (ReaderT GameEnv IO)
