echo "*************************************************";
echo "*  NAME    : xnyh.sh                           *";
echo "*  SUBJECT : �����Ż�                           *";
echo "*  DATE    : 2019-08-26                         *";
echo "*  AUTHOR  : zp                                 *";
echo "*************************************************";

####���ö�����####
#cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
####history�������####
sed -i 's/HISTSIZE=[0-9]\+/HISTSIZE=9999/g' /etc/profile
source /etc/profile
sed -i "N;10 a export HISTTIMEFORMAT=\'%F %T\'" /root/.bash_profile
source /root/.bash_profile
####linux�ļ����������µ�¼����Ч��####
sed -i 'N;42 a * - nofile 65536' /etc/security/limits.conf



