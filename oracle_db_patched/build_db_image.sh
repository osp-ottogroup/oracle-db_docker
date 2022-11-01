# Build patched Oracle database image
# Peter Ramm, 25.03.2021

# Parameter : Database version, supported values:
#   12.1.0.2-ee
#   12.1.0.2-se2
#   12.2.0.1-ee
#   12.2.0.1-se2
#   18.3.0.0-ee
#   18.3.0.0-se2
#   19.3.0.0-ee
#   19.3.0.0-se2

# Use this script instead of building directly with dockerfiles
if [ $# -ne 3 ]
then
  echo "Parameters missing! Syntax: build_db_image <version> <patchfile> <opatchfile>"
  exit 1
fi

export VERSION=$1
export PATCHFILE=$2
export OPATCHFILE=$3
export BASE_IMAGE=oracle/database:${VERSION}

echo "Building patched Oracle database from $BASE_IMAGE"

# get environment from base image and replace in Dockerfile
docker inspect ${BASE_IMAGE} | jq ".[0].Config.Env" |
  sed 's/"//g; s/,//; s/^/ENV /; s/\//\\\//g'  |
  grep -v "\[" | grep -v "\]" |
  awk '{printf "%s\\n", $0}' > base.env

sed "s/BASE_ENV/$(cat base.env)/" Dockerfile > Dockerfile.modified

# add --squash if it is not experimental no more
docker build \
    --no-cache \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    --build-arg PATCHFILE=$PATCHFILE \
    --build-arg OPATCHFILE=$OPATCHFILE \
    -f Dockerfile.modified \
    -t oracle/database_patched:$VERSION \
    -m 3g .

