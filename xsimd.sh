package: xsimd
version: "8.1.0"
tag: 8.1.0
source: https://github.com/xtensor-stack/xsimd
requires:
  - Clang:(?!.*osx)
build_requires:
  - alibuild-recipe-tools
  - CMake
  - ninja
---

mkdir -p $INSTALLROOT
cd $BUILDDIR

cmake $SOURCEDIR                          \
      -G Ninja                            \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5

cmake --build . -- ${JOBS+-j $JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib > "$MODULEFILE"
