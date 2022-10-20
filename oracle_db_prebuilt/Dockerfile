# Build Oracle database image with read to use database instance for immediate start
# Based on image created with Dockerfile from https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance/dockerfiles/12.1.0.2
# Peter Ramm, 10.01.2019

# Usage:
# increasing memory available for docker to 3GB via Docker > Preferences... > Advanced > Ram. It defaults to only 2 GB (on mac).
# Build image:                    > docker build --no-cache --build-arg VERSION=$VERSION -t oracle/database_prebuilt:${VERSION} -m 3g .
# Create container from image:    > docker run --name oracle_db_prebuilt_${VERSION} -p1521:1521 -d oracle/database_prebuilt:${VERSION}
# use ./build_db_image.sh to start build

# Default if no argument is given from docker build
ARG VERSION=0.0.0-ee

FROM oracle/database:${VERSION}
MAINTAINER Peter Ramm <Peter.Ramm@ottogroup.com>

ARG ORACLE_SID=ORCLCDB
ARG ORACLE_PDB=ORCLPDB1
# ARG is reset by FROM clause therrfore ARG must be doubled here
ARG VERSION=0.0.0-ee

ENV ORACLE_SID=$ORACLE_SID \
    ORACLE_PDB=$ORACLE_PDB \
    ORACLE_PWD=oracle \
    ORACLE_CHARACTERSET=AL32UTF8

COPY    install_db_in_build.sh run_db_in_container.sh $ORACLE_BASE/

# Check Environment
#RUN     id
#RUN     df -h
#RUN     free -h
# Create database instance
RUN     /bin/sh -c "$ORACLE_BASE/install_db_in_build.sh"

EXPOSE  1521 5500
# use bracket syntax to ensure that run_db_in_container.sh runs with PID 1 and receives SIGTERM signal
CMD ["/bin/sh", "-c", "$ORACLE_BASE/run_db_in_container.sh"]

HEALTHCHECK --interval=1m --start-period=30s CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || exit 1


