package: mesos-agent
version: v1.1.1
source: https://git-wip-us.apache.org/repos/asf/mesos.git
tag: 1.1.1
requires:
- mesos
- aurora-server
- GCC-Toolchain
- airflow-executor
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
module load BASE/1.0 ${GCC_TOOLCHAIN_ROOT:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION} glog/$GLOG_VERSION-$GLOG_REVISION ${PROTOBUF_VERSION:+protobuf/$PROTOBUF_VERSION-$PROTOBUF_REVISION} mesos/${MESOS_VERSION}-${MESOS_REVISION} aurora-server/${AURORA_SERVER_VERSION}-${AURORA_SERVER_REVISION} airflow-executor/${AIRFLOW_EXECUTOR_VERSION}-${AIRFLOW_EXECUTOR_REVISION}
EoF
