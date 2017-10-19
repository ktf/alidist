package: mesos
version: v1.1.1
source: https://git-wip-us.apache.org/repos/asf/mesos.git
tag: 1.1.1
requires:
- protobuf
- glog
- Python
- GCC-Toolchain
build_requires:
- autotools
prepend_path:
  PATH: "$MESOS_ROOT/sbin"
  PYTHONPATH: $MESOS_ROOT/lib/python2.7/site-packages
---

rsync -av --delete --exclude="**/.git" $SOURCEDIR/ .
./bootstrap
mkdir build
cd build

# PYTHON_VERSION with vXXX seems to confuse configure
unset PYTHON_VERSION
../configure --prefix="$INSTALLROOT"         \
             --enable-python                 \
             --disable-java                  \
             --with-glog=${GLOG_ROOT}        \
             --with-protobuf=${PROTOBUF_ROOT}

# We build with fewer jobs to avoid OOM errors in GCC
make -j 4
make install

find $BUILDDIR/build/src/python/dist -name "*.egg" -exec cp {} $INSTALLROOT/lib/python2.7/site-packages/ \;

cat << EOF > $INSTALLROOT/etc/mesos-modules
{
  "libraries":
  [
    {
      "file": "$INSTALLROOT/lib/mesos/modules/libfixed_resource_estimator.so",
      "modules": {
        "name": "org_apache_mesos_FixedResourceEstimator",
        "parameters": {
          "key": "resources",
          "value": "cpus:$((`nproc` + ${MESOS_EXTRA_CPUS:-0}))"
        }
      }
    },
    {
      "file": "$INSTALLROOT/lib/mesos/modules/libload_qos_controller.so",
      "modules": {
        "name": "org_apache_mesos_LoadQoSController",
        "parameters": [
          {
            "key": "load_threshold_5min",
            "value": "$((`nproc` + ${MESOS_EXTRA_CPUS:-0} + 3))"
          },
          {
            "key": "load_threshold_15min",
            "value": "$((`nproc` + ${MESOS_EXTRA_CPUS:-0} + 2))"
          }
        ]
      }
    }
  ]
}
EOF

cat << \EOF > $INSTALLROOT/bin/executor-environment.json.sh
cat << EOF2 
{
"PATH": "$PATH",
"LD_LIBRARY_PATH": "$LD_LIBRARY_PATH",
"LD_PRELOAD": "$LD_PRELOAD"
}
EOF2
EOF
chmod u+x $INSTALLROOT/bin/executor-environment.json.sh

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
