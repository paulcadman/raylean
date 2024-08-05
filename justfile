raylib_release_path := join(justfile_directory(), "lib")
raylib_src_path := join(justfile_directory(), "raylib-5.0", "src")

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
            CUSTOM_CFLAGS="-target arm64-apple-macos11 -DGL_SILENCE_DEPRECATION -fno-objc-msgsend-selector-stubs"
    fi

build: build_raylib
    lake build

clean:
    lake clean

clean_raylib:
    make -C {{raylib_src_path}} clean
    rm -rf {{raylib_release_path}}

clean_all: clean clean_raylib

run: build
    .lake/build/bin/raylib-lean
