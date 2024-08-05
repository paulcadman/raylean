build_raylib:
    # This build differs from the raylib release workflow.
    # We require `-fno-objc-msgsend-selector-stubs` to be set.
    #
    # If this is not set then the clang 15 linker bundled with lean gives the
    # following error:
    #
    #   ld64.lld: error: undefined symbol: _objc_msgSend$update
    #
    # See https://stackoverflow.com/a/74054943
    make -C raylib-5.0/src CC=/usr/bin/clang PLATFORM=PLATFORM_DESKTOP RAYLIB_LIBTYPE=STATIC CUSTOM_CFLAGS="-target arm64-apple-macos11 -DGL_SILENCE_DEPRECATION -fno-objc-msgsend-selector-stubs"

build: build_raylib
    lake build

clean:
    lake clean

clean_raylib:
    make -C raylib-5.0/src clean

clean_all: clean clean_raylib

run: build
    .lake/build/bin/raylib-lean
