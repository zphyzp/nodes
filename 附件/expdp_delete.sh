#echo "*  NAME    : expdp_delete_sh                    *";
#echo "*  SUBJECT : BJGTJ PRODUCT BACKUP               *";
#echo "*  DATE    : 2015-03-23                         *";
#echo "*  AUTHOR  : zy                                 *";
#echo "*                                               *";
#echo "*                                               *";
#echo "***********************************************";


expdpDate=`date +"%Y%m%d"`;
expiredate=$(perl -e "use POSIX qw(strftime); print strftime '%Y%m%d',localtime(time()-3600*24*9)")
echo "  *****expdp delete start  time ${expdpDate} ******* "
cd /backup/expdp_backup
rm -rf *${expiredate}.dmp*
rm -rf *${expiredate}.log

