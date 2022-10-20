# Build Oracle database image 
# Peter Ramm, 16.04.2019

# Parameter : Database version, supported values:
#   12.1.0.2-ee
#   12.1.0.2-se2
#   12.2.0.1-ee
#   12.2.0.1-se2
#   18.3.0.0-ee
#   18.3.0.0-se2


# Use this script instead of building directly with dockerfiles
if [ $# -ne 1 ]
then
  echo "Syntax: build_db_image <version> <patchfile>"
  echo "Parameter VERSION expected! Like '12.1.0.2-ee'"
  exit 1
fi

export VERSION=$1

if [[ $VERSION == *"xe"* ]]; then
  export ORACLE_SID=XE
  export ORACLE_PDB=XEPDB1
else
  export ORACLE_SID=ORCLCDB
  export ORACLE_PDB=ORCLPDB1
fi

echo "Building Oracle database for version = $VERSION"

# add --squash if it is not experimental no more
# Disable DOCKER_BUILDKIT as workaround for "/sys/fs/cgroup/memory.max no such file or directory" see: https://github.com/oracle/docker-images/issues/2334
DOCKER_BUILDKIT=0 docker build \
    --no-cache \
    --build-arg VERSION=$VERSION \
    --build-arg ORACLE_SID=$ORACLE_SID \
    --build-arg ORACLE_PDB=$ORACLE_PDB \
    --progress=plain \
    -t oracle/database_prebuilt:$VERSION \
    -m 3g .

