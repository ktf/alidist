package: IgProf
version: 5.9.18
tag: v5.9.18
source: http://github.com/igprof/igprof.git
requires:
  - libunwind:(?!osx)
build_requires:
  - CMake
  - ninja
  - alibuild-recipe-tools
---
#!/bin/sh

cmake $SOURCEDIR \
      -G Ninja \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                                                                  \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      ${UNWIND_REVISION:+-DUNWIND_INCLUDE_DIR=$LIBUNWIND_ROOT/include} \
      ${UNWIND_REVISION:+-DUNWIND_LIBRARY=$LIBUNWIND_ROOT/lib/libunwind.so} \
      -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-g -O3 -U_FORTIFY_SOURCE -Wno-attributes -Wno-pedantic"
cmake --build . -- ${JOBS:+-j$JOBS} install

ls -al
cp ${BUILDDIR}/compile_commands.json ${INSTALLROOT}

DEVEL_SOURCES="`readlink $SOURCEDIR || echo $SOURCEDIR`"
# This really means we are in development mode. We need to make sure we
# use the real path for sources in this case. We also copy the
# compile_commands.json file so that IDEs can make use of it directly, this
# is a departure from our "no changes in sourcecode" policy, but for a good reason
# and in any case the file is in gitignore.
if [ "$DEVEL_SOURCES" != "$SOURCEDIR" ]; then
  perl -p -i -e "s|$SOURCEDIR|$DEVEL_SOURCES|" compile_commands.json
  ln -sf $BUILDDIR/compile_commands.json $DEVEL_SOURCES/compile_commands.json
fi
# Modulefile
mkdir -p etc/modulefiles
alibuild-generate-module --bin --lib > etc/modulefiles/$PKGNAME
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
