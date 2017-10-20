package: airflow-executor
version: "1.0"
requires:
  - Python
  - mesos
build_requires:
  - curl
env:
  PYTHONPATH: $PYTHON_MODULES_ROOT/lib/python2.7/site-packages:$PYTHONPATH
---
#!/bin/bash -ex

# Force pip installation of packages found in current PYTHONPATH
unset PYTHONPATH

# The X.Y in pythonX.Y
export PYVER=$(python -c 'import distutils.sysconfig; print(distutils.sysconfig.get_python_version())')

# Install as much as possible with pip. Packages are installed one by one as we
# are not sure that pip exits with nonzero in case one of the packages failed.
export PYTHONUSERBASE=$INSTALLROOT
for X in "airflow[s3,postgres,kerberos,hdfs,crypto,ldap,slack]" \
	 "certifi"
do
  pip install --user $X
done
unset PYTHONUSERBASE

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
module load BASE/1.0 ${PYTHON_VERSION:+Python/$PYTHON_VERSION-$PYTHON_REVISION}
# Our environment
setenv AIRFLOW_EXECUTOR_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH $::env(AIRFLOW_EXECUTOR_ROOT)/bin
prepend-path LD_LIBRARY_PATH $::env(AIRFLOW_EXECUTOR_ROOT)/lib64
prepend-path LD_LIBRARY_PATH $::env(AIRFLOW_EXECUTOR_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH $::env(AIRFLOW_EXECUTOR_ROOT)/lib64" && \
                                      echo "prepend-path DYLD_LIBRARY_PATH $::env(AIRFLOW_EXECUTOR_ROOT)/lib")
prepend-path PYTHONPATH $::env(AIRFLOW_EXECUTOR_ROOT)/lib/python$PYVER/site-packages
setenv SSL_CERT_FILE  [exec python -c "import certifi; print certifi.where()"]
EoF
