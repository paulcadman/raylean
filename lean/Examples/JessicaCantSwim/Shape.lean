namespace Shape

structure Vector2 where
  x : Float
  y : Float
  deriving Inhabited

structure Rectangle where
  /-- Rectangle top-left corner position x -/
  x : Float
  /-- Rectangle top-left corner position y -/
  y : Float
  /-- Rectangle width -/
  width : Float
  /-- Rectangle height -/
  height : Float

end Shape
