package: DuckDB
version: "v0.5.1"
source: https://github.com/duckdb/duckdb.git
requires:
  - arrow
  - fmt
build_requires:
  - CMake
---
cmake $SOURCEDIR -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -G Ninja

ninja install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module > "$MODULEFILE"
