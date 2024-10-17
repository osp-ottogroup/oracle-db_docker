# Build Oracle database image with read to use database instance for immediate start
# Peter Ramm, 10.01.2019

# Usage:
# increasing memory available for docker to 3GB via Docker > Preferences... > Advanced > Ram. It defaults to only 2 GB (on mac).
# use ./build_db_image.sh to start build

# Default if no argument is given from docker build
ARG BASE_IMAGE=image:0.0.0.0-ee

FROM ${BASE_IMAGE} as base
MAINTAINER Peter Ramm <Peter.Ramm@ottogroup.com>

ARG ORACLE_SID=ORCLCDB
ARG ORACLE_PDB=ORCLPDB1
# ARG is reset by FROM clause therefore ARGs must be doubled here

ENV ORACLE_SID=$ORACLE_SID \
    ORACLE_PDB=$ORACLE_PDB \
    ORACLE_PWD=oracle \
    ORACLE_CHARACTERSET=AL32UTF8

USER    root
RUN  microdnf install procps

USER    oracle
COPY    install_db_in_build.sh run_db_in_container.sh $ORACLE_BASE/

# Check Environment
#RUN     id
#RUN     df -h
#RUN     free -h
# Create database instance
RUN     /bin/sh -c "$ORACLE_BASE/install_db_in_build.sh"

USER    root
RUN     rm -rf /var/log/*

# Update OS to current patch state
RUN     microdnf update  && microdnf clean all

FROM scratch

# Ensure the ORACLE_SID is set in the created image, required for "sqlplus / as sysdba"
ARG ORACLE_SID
ENV ORACLE_SID=$ORACLE_SID

# next line will be replaced with ENV of BASE_IMAGE before docker build
BASE_ENV

COPY --from=base / /

USER    oracle

WORKDIR /home/oracle

EXPOSE  1521 5500
# use bracket syntax to ensure that run_db_in_container.sh runs with PID 1 and receives SIGTERM signal
CMD ["/bin/sh", "-c", "$ORACLE_BASE/run_db_in_container.sh"]

HEALTHCHECK --interval=1m --start-period=30s CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || exit 1


