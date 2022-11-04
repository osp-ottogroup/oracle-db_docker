# Build Oracle database image with read to use database instance for immediate start
# Based on image created with Dockerfile from https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance/dockerfiles/12.1.0.2
# Peter Ramm, 10.01.2019

# Usage:
# use ./build_db_image.sh to start build

# Default if no argument is given from docker build
ARG BASE_IMAGE

FROM ${BASE_IMAGE} as unpatched
MAINTAINER Peter Ramm <Peter.Ramm@ottogroup.com>

# ARG is reset by FROM clause therrfore ARG must be doubled here
ARG VERSION
ARG PATCHFILE
ARG OPATCHFILE

# Update basic OS
USER    root
RUN     yum -y update && yum clean all

USER    oracle
RUN     mkdir $ORACLE_BASE/patch
COPY    $PATCHFILE $OPATCHFILE $ORACLE_BASE/patch/

RUN     cd $ORACLE_BASE/patch && \
        unzip $PATCHFILE && \
        unzip $OPATCHFILE && \
        mkdir -p $ORACLE_HOME/assistants/dbua/jlib && touch $ORACLE_HOME/assistants/dbua/jlib/dbma.jar && \
        cd $(ls | grep -v zip | grep -v OPatch) && \
        ../OPatch/opatch apply -silent -force && \
        rm -r $ORACLE_BASE/patch && \
        # Remove unnecessary files/folders from filesystem
        # APEX
        rm -rf $ORACLE_HOME/apex && \
        # ORDS
        rm -rf $ORACLE_HOME/ords && \
        # SQL Developer
        rm -rf $ORACLE_HOME/sqldeveloper && \
        # UCP connection pool
        rm -rf $ORACLE_HOME/ucp && \
        # All installer files
        rm -rf $ORACLE_HOME/lib/*.zip && \
        # OUI backup
        rm -rf $ORACLE_HOME/inventory/backup/* && \
        # Network tools help
        rm -rf $ORACLE_HOME/network/tools/help && \
        # Database upgrade assistant
        rm -rf $ORACLE_HOME/assistants/dbua && \
        # Database migration assistant
        rm -rf $ORACLE_HOME/dmu && \
        # Remove pilot workflow installer
        rm -rf $ORACLE_HOME/install/pilot && \
        # Support tools
        rm -rf $ORACLE_HOME/suptools && \
#        # local OPatch
#        rm -rf $ORACLE_HOME/OPatch && \
        # Temp location
        rm -rf /tmp/*

USER    root
RUN     rm -rf /var/log/*

# Update OS to current patch state
RUN     yum -y update

# Start fresh filesystem with current state
FROM scratch

# next line will be replaced with ENV of BASE_IMAGE before docker build
BASE_ENV

COPY --from=unpatched / /

USER    oracle

WORKDIR /home/oracle

# CMD cloned from database image
CMD ["/bin/sh", "-c", "exec $ORACLE_BASE/$RUN_FILE"]

# Healthcheck cloned from database image
HEALTHCHECK --interval=1m --start-period=30s CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || exit 1





