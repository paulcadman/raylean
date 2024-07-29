import Lake
open System Lake DSL

-- TODO: How to support this more generally?
def raylibPath := "/opt/homebrew/opt/raylib"

package «lean-raylib» where
  moreLinkArgs := #["-lraylib", s!"-L{raylibPath}/lib/"]
  srcDir := "lean"
  -- add package configuration options here

lean_lib «Raylib» where
  precompileModules := true

@[default_target]
lean_exe «lean-raylib» where
  root := `Main

target raylib_bindings.o pkg : FilePath := do
  let oFile := pkg.buildDir / "c" / "raylib_bindings.o"
  let srcJob ← inputFile <| pkg.dir / "c" / "raylib_bindings.c"
  -- The clang headers are specified with the `isystem` flag so that warnings are ignored
  let weakArgs := #["-I", (← getLeanIncludeDir).toString, "-I", s!"{raylibPath}/include", "-isystem", ((← getLeanIncludeDir) / "clang").toString]
  buildO oFile srcJob weakArgs #["-fPIC"] (← getLeanCc) getLeanTrace

extern_lib libleanffi pkg := do
  let ffiO ← raylib_bindings.o.fetch
  let name := nameToStaticLib "leanraylib"
  buildStaticLib (pkg.nativeLibDir / name) #[ffiO]
