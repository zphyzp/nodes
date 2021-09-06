#echo "*  NAME    : expdp_sh                           *";
#echo "*  SUBJECT : BJGTJ PRODUCT BACKUP               *";
#echo "*  DATE    : 2015-10-20                         *";
#echo "*  AUTHOR  : zy                                 *";
#echo "*                                               *";
#echo "*                                               *";
#echo "***********************************************";
export ORACLE_BASE=/oracle/app
export ORACLE_HOME=$ORACLE_BASE/11.2.0.4/db_home
export ORA_GRID_HOME=/oracle/crs/
export ORACLE_OWNER=oracle
export ORACLE_SID=bdc2
export PATH=$PATH:$ORACLE_HOME/bin:$ORA_GRID_HOME/bin:/sbin:/usr/sbin:/bin:/usr/local/bin:.
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlib
export NLS_LANG=american_america.ZHS16GBK
export ORACLE_PATH=/home/oracle

expdpdate=`date +"%Y%m%d"`;
#expiredate=$(perl -e "use POSIX qw(strftime); print strftime '%Y%m%d',localtime(time()-3600*24*6)")
echo "  *****expdp backup start  time ${expdpdate} ******* "

expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=rt_from dumpfile=rt_from_${expdpdate}.dmp logfile=rt_from_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=gis dumpfile=gis_${expdpdate}.dmp logfile=gis_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=sm dumpfile=sm_${expdpdate}.dmp logfile=sm_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=houseplatform dumpfile=houseplatform_${expdpdate}.dmp logfile=houseplatform_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=afsin dumpfile=afsin_${expdpdate}.dmp logfile=afsin_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=rt_to dumpfile=rt_to_${expdpdate}.dmp logfile=rt_to_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=ttia dumpfile=ttia_${expdpdate}.dmp logfile=ttia_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=surveycache dumpfile=surveycache_${expdpdate}.dmp logfile=surveycache_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=pubr dumpfile=pubr_${expdpdate}.dmp logfile=pubr_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=tt dumpfile=tt_${expdpdate}.dmp logfile=tt_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=ap dumpfile=ap_${expdpdate}.dmp logfile=ap_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=archive dumpfile=archive_${expdpdate}.dmp logfile=archive_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=ttfehcashia dumpfile=ttfehcashia_${expdpdate}.dmp logfile=ttfehcashia_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=pb dumpfile=pb_${expdpdate}.dmp logfile=pb_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=tt_contract dumpfile=tt_contract_${expdpdate}.dmp logfile=tt_contract_${expdpdate}.log
expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=digitalscan dumpfile=digitalscan_${expdpdate}.dmp logfile=digitalscan_${expdpdate}.log

cd /backup/expdp_backup
gzip rt_from_${expdpdate}.dmp
gzip gis_${expdpdate}.dmp
gzip sm_${expdpdate}.dmp
gzip houseplatform_${expdpdate}.dmp
gzip afsin_${expdpdate}.dmp
gzip rt_to_${expdpdate}.dmp
gzip ttia_${expdpdate}.dmp
gzip surveycache_${expdpdate}.dmp
gzip pubr_${expdpdate}.dmp
gzip tt_${expdpdate}.dmp
gzip ap_${expdpdate}.dmp
gzip archive_${expdpdate}.dmp
gzip ttfehcashia_${expdpdate}.dmp
gzip pb_${expdpdate}.dmp
gzip tt_contract_${expdpdate}.dmp
gzip digitalscan_${expdpdate}.dmp

dbExportDate=`date +%Y-%m-%d" "%H:%M:%S`;
echo "业务生产库导出完毕end time ${expdpdate}";
