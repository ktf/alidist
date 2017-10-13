package: aurora-server
version: alice1
source: https://github.com/alisw/aurora
tag: alice/0.16.0
requires:
- mesos
---
#!/bin/bash -ex
export MESOS_VERSION

rsync -a $SOURCEDIR/ ./
mkdir -p third_party
find $MESOS_ROOT/lib/python2.7/site-packages/ -name "*.egg" -exec cp {} third_party/ \;

./pants binary src/main/python/apache/aurora/executor:thermos_executor
./pants binary src/main/python/apache/aurora/tools:thermos_observer
./pants binary src/main/python/apache/thermos/runner:thermos_runner
./build-support/embed_runner_in_executor.py

mkdir -p $INSTALLROOT/bin
cp dist/thermos_executor.pex $INSTALLROOT/bin/thermos_executor
cp dist/thermos_observer.pex $INSTALLROOT/bin/thermos_observer
cp dist/thermos_runner.pex $INSTALLROOT/bin/thermos_runner

# Modulefile
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
module load BASE/1.0 mesos/$MESOS_VERSION-$MESOS_REVISION
# Our environment
setenv AURORA_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH $::env(AURORA_ROOT)/bin
prepend-path LD_LIBRARY_PATH $::env(AURORA_ROOT)/lib
prepend-path PERL5LIB $::env(AURORA_ROOT)/lib/perl5
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH $::env(AURORA_ROOT)/lib")
EoF
