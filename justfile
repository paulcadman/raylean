build:
    lake build

clean:
    lake clean

run: build
    .lake/build/bin/raylib-lean
