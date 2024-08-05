import Lake
open System Lake DSL

-- TODO: How to support this more generally?
def raylibPath := "/opt/homebrew/opt/raylib"

package «lean-raylib» where
  srcDir := "lean"

lean_lib «Raylib» where
  precompileModules := true

lean_lib «Examples» where
  precompileModules := true

@[default_target]
lean_exe «raylib-lean» where
  root := `Main
  moreLinkArgs := #["-lraylib", s!"-L{raylibPath}/lib/"]

target raylib_bindings.o pkg : FilePath := do
  let oFile := pkg.buildDir / "c" / "raylib_bindings.o"
  let srcJob ← inputFile <| pkg.dir / "c" / "raylib_bindings.c"
  let raylibInclude := pkg.dir / "raylib-5.0" / "include"
  let weakArgs := #["-I", (← getLeanIncludeDir).toString,
                    "-I", s!"{raylibInclude}",
                    -- The clang headers are specified with the `isystem` flag so that warnings are ignored
                    "-isystem", ((← getLeanIncludeDir) / "clang").toString]
  buildO oFile srcJob weakArgs #["-fPIC"] (← getLeanCc) getLeanTrace

extern_lib libleanffi pkg := do
  let ffiO ← raylib_bindings.o.fetch
  let name := nameToStaticLib "rayliblean"
  buildStaticLib (pkg.nativeLibDir / name) #[ffiO]
