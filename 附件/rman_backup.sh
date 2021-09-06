export ORACLE_SID=bdc1
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/db_home
$ORACLE_HOME/bin/rman target sys/jwdb*SYS5 cmdfile='/home/oracle/script/backup.rman' log="/backup/log/fullbak_`date +%Y-%m-%d`.log" nocatalog
