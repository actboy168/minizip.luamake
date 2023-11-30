local lm = require "luamake"

local ZLIBDIR = "zlib-ng/"
local MINIZIPDIR = "minizip-ng/"

lm:runlua "gen-zconf" {
    script = "configure_file.lua",
    args = { "$in", "$out" },
    input = ZLIBDIR.."zconf-ng.h.in",
    output = "$builddir/gen-zlib/zconf-ng.h",
}

lm:runlua "gen-zlib" {
    script = "configure_file.lua",
    args = { "$in", "$out" },
    input = ZLIBDIR.."zlib-ng.h.in",
    output = "$builddir/gen-zlib/zlib-ng.h",
}

lm:runlua "gen-zlib_name_mangling" {
    script = "configure_file.lua",
    args = { "$in", "$out" },
    input = ZLIBDIR.."zlib_name_mangling.h.empty",
    output = "$builddir/gen-zlib/zlib_name_mangling-ng.h",
}

lm:source_set "zlib-ng" {
    objdeps = {
        "gen-zconf",
        "gen-zlib",
        "gen-zlib_name_mangling",
    },
    includes = {
        ZLIBDIR,
        "$builddir/gen-zlib"
    },
    sources = {
        ZLIBDIR.."*.c",
        "!"..ZLIBDIR.."gz*.c",
    },
    gcc = {
        defines = {
            "HAVE_ATTRIBUTE_ALIGNED"
        },
    },
    clang = {
        defines = {
            "HAVE_ATTRIBUTE_ALIGNED"
        },
    },
}

lm:source_set "minizip-ng" {
    defines = {
        "MZ_ZIP_NO_CRYPTO"
    },
    includes = {
        MINIZIPDIR,
        ZLIBDIR,
        "$builddir/gen-zlib",
    },
    sources = {
        MINIZIPDIR.."mz_compat.c",
        MINIZIPDIR.."mz_os.c",
        MINIZIPDIR.."mz_crypt.c",
        MINIZIPDIR.."mz_strm.c",
        MINIZIPDIR.."mz_zip.c",
        MINIZIPDIR.."mz_zip_rw.c",
        MINIZIPDIR.."mz_strm_buf.c",
        MINIZIPDIR.."mz_strm_mem.c",
        MINIZIPDIR.."mz_strm_split.c",
        MINIZIPDIR.."mz_strm_zlib.c",
    },
    windows = {
        sources = {
            MINIZIPDIR.."mz_os_win32.c",
            MINIZIPDIR.."mz_strm_os_win32.c",
        },
    },
    msvc = {
        defines = {
            "_CRT_SECURE_NO_WARNINGS"
        },
    },
}

lm:exe "minizip" {
    deps = {
        "zlib-ng",
        "minizip-ng",
    },
    sources = {
        MINIZIPDIR.."minizip.c",
    }
}
