# Create database instance during "docker build" by wrapping runOracle.sh
# Terminates install process after finishing

# Patching ORACLE_HOME
if [[ $VERSION == "12.2.0.1"* ]]
then
  # Leading 0 for numeric values < 1 in JSON_OBJECT
  cd $ORACLE_BASE
  unzip p27486853_122010_Linux-x86-64
  cd 27486853
  opatch apply -silent
  opatch lsinventory
fi

# Start installer in background
$ORACLE_BASE/$RUN_FILE &

# Wait until tail -f on alert.log occurs
while [ true ]
do 
  ps -ef | grep -v grep | grep -e "tail -f.*diag/rdbms.*trace/alert.*.log" > /dev/null
  if [ $? -eq 0 ]; then
    echo "tail -f on alert.log now occurs"
    break
  fi

  ps -ef | grep -v grep | grep $RUN_FILE > /dev/null
  if [ $? -ne 0 ]; then
    echo "ERROR: process $RUN_FILE has terminated before waiting on tail -f on alert.log"
    exit 1
  fi

  sleep 1
done

echo "running shell in docker as user:"
id

# Switch user to oracle if running as root
if [ `id -u` -eq 0 ]
then
  EXEC_CMD="su oracle -c"
else
  EXEC_CMD="sh -c"
fi

echo "Allow automatic registration of services at listener"
echo "alter system set local_listener='' scope=both;" | $EXEC_CMD "sqlplus -s / as sysdba"

echo "Terminates waiting process runOracle.sh by killing tail -f"
kill `ps -ef | grep -v grep | grep -e "tail -f.*diag/rdbms.*trace/alert.*.log" | awk '{ print $2 }'`

# This step is not needed after removal of VOLUME declaration in Oracle's dockerfiles
#echo "Save VOLUME content to other directory because VOLUME content is not persisted after docker build"
#mkdir $ORACLE_BASE/oradata_backup
#mv $ORACLE_BASE/oradata/* $ORACLE_BASE/oradata_backup/

# All o.k. if reaching this point
exit 0
