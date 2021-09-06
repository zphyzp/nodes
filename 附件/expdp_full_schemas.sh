#echo "*  NAME    : expdp_sh                           *";
#echo "*  SUBJECT : BJGTJ PRODUCT BACKUP               *";
#echo "*  DATE    : 2015-10-20                         *";
#echo "*  AUTHOR  : zy                                 *";
#echo "*                                               *";
#echo "*                                               *";
#echo "***********************************************";
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/db_home
export ORACLE_SID=bdc1
export PATH=$PATH:$ORACLE_HOME/bin:/sbin:/usr/sbin:/bin:/usr/local/bin:.
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlib
export NLS_LANG=american_america.ZHS16GBK

expdpdate=`date +"%Y%m%d"`;
#expiredate=$(perl -e "use POSIX qw(strftime); print strftime '%Y%m%d',localtime(time()-3600*24*6)")
echo "  *****expdp backup start  time ${expdpdate} ******* "

expdp for_dump/for_dump8GTJ directory=expdp_backup schemas=rt_from,gis,sm,houseplatform,afsin,rt_to,ttia,surveycache,pubr,tt,ap,archive,ttfehcashia,pb,tt_contract,digitalscan,ati dumpfile=expdp_16_${expdpdate}.dmp logfile=expdp_16_${expdpdate}.log

cd /backup/expdp_backup
gzip expdp_16_${expdpdate}.dmp

endDate=`date +%Y-%m-%d" "%H:%M:%S`;
echo "业务生产库导出完毕end time ${endDate}";
