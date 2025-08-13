# Raylib CUSTOM_FLAGS tailed for the current os
#
# The macos differ from the raylib release workflow.
# We require `-fno-objc-msgsend-selector-stubs` to be set.
#
# If this is not set then the clang 15 linker bundled with lean gives the
# following error:
#
#   ld64.lld: error: undefined symbol: _objc_msgSend$update
#
# See https://stackoverflow.com/a/74054943
#
raylib_os_custom_cflags := if os() == "macos" { "-target arm64-apple-macos11 -DGL_SILENCE_DEPRECATION -fno-objc-msgsend-selector-stubs"  } else { "" }

# Enable extra raylib configuration flags
raylib_config_flags := ""

# Raylib CUSTOM_CFLAGS make parameter
raylib_custom_cflags := raylib_config_flags + " " + raylib_os_custom_cflags

# Raylib CC make paramter
raylib_cc_parameter := if os() == "macos" { "/usr/bin/clang" } else { "gcc" }

# Raylib extra Makefile variables
#
# e.g add "USE_WAYLAND_DISPLAY=TRUE" to build Raylib with Wayland support.
raylib_extra_make_variables := ""

static_lib_path := join(justfile_directory(), "lib")
raylib_src_path := join(justfile_directory(), "raylib-5.0", "src")

# set to the C compiler used to build native libraries (e.g raylib CC, and lake LEAN_CC)
native_compiler := if os() == "macos" { "/usr/bin/clang" } else { "clang" }

# The path to the GMP library root
#
# On macOS use `brew install gmp` to install it
gmp_prefix := if os() == "macos" { shell("brew --prefix gmp") } else { "" }

# The path to libuv root
#
# On macOS use `brew install libuv` to install it
libuv_prefix := if os() == "macos" { shell("brew --prefix libuv") } else { "" }

# The value of LIBRARY_PATH used when running `just build`. This is passed to
# the C compiler when lake builds native objects.
library_path := if gmp_prefix == "" { "" } else if libuv_prefix == "" { "" } else {gmp_prefix + "/lib:" + libuv_prefix + "/lib"}

[private]
default:
    @just --list

# build only the raylib static library
build_raylib:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "{{static_lib_path}}/libraylib.a" ]; then
        mkdir -p {{static_lib_path}}
        make -C {{raylib_src_path}} \
            CC={{raylib_cc_parameter}} \
            PLATFORM=PLATFORM_DESKTOP \
            RAYLIB_LIBTYPE=STATIC \
            RAYLIB_RELEASE_PATH={{static_lib_path}} \
            {{raylib_extra_make_variables}} \
            CUSTOM_CFLAGS="{{raylib_custom_cflags}}"
    fi

# build both the raylib library and the Lake project
build: build_raylib
    LIBRARY_PATH={{library_path}} LEAN_CC={{native_compiler}} lake build

# clean only the Lake project
clean:
    lake clean

clean_static_lib:
    rm -rf {{static_lib_path}}

# clean only the raylib build
clean_raylib:
    make -C {{raylib_src_path}} clean
    rm -rf {{static_lib_path}}/libraylib.a

# clean both the raylib build and the Lake project
clean_all: clean clean_raylib clean_static_lib

# run the demo executable
run: build
    .lake/build/bin/jessicacantswim
