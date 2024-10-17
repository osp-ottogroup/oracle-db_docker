#!/bin/bash
# run DB by runOracle.sh
# link preinstalled database files to VOLUME $ORACLE_BASE/oradata at first startup

# This step is not needed after removal of VOLUME declaration in Oracle's dockerfiles
# if [ `ls $ORACLE_BASE/oradata | wc -l` -eq 0 ]; then
#   echo "`date` First start of container, link files from $ORACLE_BASE/oradata_backup into $ORACLE_BASE/oradata"
#   cd $ORACLE_BASE/oradata
#
#   for file in `ls $ORACLE_BASE/oradata_backup`; do
#     ln -s $ORACLE_BASE/oradata_backup/$file $file
#     if [ $? -ne 0 ]
#     then
#       echo "`date` Error creating link to $ORACLE_BASE/oradata_backup/$file in $ORACLE_BASE/oradata"
#     fi
#   done

#   echo "`date` Finished creating links to $ORACLE_BASE/oradata_backup in $ORACLE_BASE/oradata"

#  echo "Size of subdirs at volume $ORACLE_BASE/oradata_backup"
# du -sh $ORACLE_BASE/oradata_backup/*
#  echo ""


# else
#   echo "Subsequent start of container, using existing files in $ORACLE_BASE/oradata"
# fi

echo "Size of subdirs at volume $ORACLE_BASE/oradata"
du -sh $ORACLE_BASE/oradata/*
echo ""

# The container entrypoint used for ghcr.io/gvenzl/oracle-free etc.
if [ -z "$RUN_FILE" ]; then
  export RUN_FILE=container-entrypoint.sh
fi

# Start database, ensure the script replaces the current one and receives SIGTERM
exec $ORACLE_BASE/$RUN_FILE
