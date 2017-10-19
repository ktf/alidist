package: mesos-agent
version: v1.1.1
source: https://git-wip-us.apache.org/repos/asf/mesos.git
tag: 1.1.1
requires:
- mesos
- aurora-server
---

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
module load BASE/1.0 ${GCC_TOOLCHAIN_ROOT:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION} glog/$GLOG_VERSION-$GLOG_REVISION ${PROTOBUF_VERSION:+protobuf/$PROTOBUF_VERSION-$PROTOBUF_REVISION}
# Our environment
setenv MESOS_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv MESOS_LAUNCHER_DIR \$::env(MESOS_ROOT)/libexec/mesos
setenv MESOS_MODULES file://\$::env(MESOS_ROOT)/etc/mesos-modules
prepend-path PYTHONPATH \$::env(MESOS_ROOT)/lib/python2.7/site-packages
prepend-path LD_LIBRARY_PATH \$::env(MESOS_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(MESOS_ROOT)/lib")
prepend-path PATH \$::env(MESOS_ROOT)/bin
prepend-path PATH \$::env(MESOS_ROOT)/sbin
EoF
