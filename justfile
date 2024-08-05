raylib_release_path := join(justfile_directory(), "lib")
raylib_src_path := join(justfile_directory(), "raylib-5.0", "src")
extra_raylib_config_flags := "-DSUPPORT_FILEFORMAT_SVG"

[private]
default:
    @just --list

# build only the raylib static library
build_raylib:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "{{raylib_release_path}}/libraylib.a" ]; then
        mkdir -p {{raylib_release_path}}
        # This build differs from the raylib release workflow.
        # We require `-fno-objc-msgsend-selector-stubs` to be set.
        #
        # If this is not set then the clang 15 linker bundled with lean gives the
        # following error:
        #
        #   ld64.lld: error: undefined symbol: _objc_msgSend$update
        #
        # See https://stackoverflow.com/a/74054943
        #
        make -C {{raylib_src_path}} \
            CC=/usr/bin/clang \
            PLATFORM=PLATFORM_DESKTOP \
            RAYLIB_LIBTYPE=STATIC \
            RAYLIB_RELEASE_PATH={{raylib_release_path}} \
            CUSTOM_CFLAGS="{{extra_raylib_config_flags}} -target arm64-apple-macos11 -DGL_SILENCE_DEPRECATION -fno-objc-msgsend-selector-stubs"
    fi

# build both the raylib library and the Lake project
build: build_raylib
    lake build

# clean only the Lake project
clean:
    lake clean

# clean only the raylib build
clean_raylib:
    make -C {{raylib_src_path}} clean
    rm -rf {{raylib_release_path}}

# clean both the raylib build and the Lake project
clean_all: clean clean_raylib

# run the demo executable
run: build
    .lake/build/bin/raylib-lean
