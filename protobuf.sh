package: protobuf
version: v2.6.1
source: https://github.com/google/protobuf
requires:
 - Python
build_requires:
 - autotools
 - "GCC-Toolchain:(?!osx)"
prefer_system_check: |
   printf "#include <google/protobuf/stubs/common.h>\n#if (GOOGLE_PROTOBUF_VERSION < 2006001)\n#error \"System protobuf cannot be used, please install a version >= 2.6.1\"\n#endif\n" | cc -xc++ - -c -o /dev/null && protoc --version
prepend_path:
  PYTHONPATH: $PROTOBUF_ROOT/lib/python2.7/site-packages/protobuf-${PROTOBUF_VERSION:1}-py2.7.egg
---

rsync -av --delete --exclude="**/.git" $SOURCEDIR/ .
autoreconf -ivf
./configure --prefix="$INSTALLROOT"
make ${JOBS:+-j $JOBS}
make install

pushd python
  export PYTHONUSERBASE=$INSTALLROOT
  python setup.py build
  mkdir -p $INSTALLROOT/lib/python2.7/site-packages
  python setup.py install --user
  unset PYTHONUSERBASE
popd

#ModuleFile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 ${PYTHON_VERSION:+Python/${PYTHON_VERSION}-${PYTHON_REVISION}}
# Our environment
setenv PROTOBUF_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(PROTOBUF_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(PROTOBUF_ROOT)/lib")
prepend-path PATH \$::env(PROTOBUF_ROOT)/bin
prepend-path PYTHONPATH \$::env(PROTOBUF_ROOT)/lib/python2.7/site-packages/protobuf-${PKGVERSION:1}-py2.7.egg
EoF
