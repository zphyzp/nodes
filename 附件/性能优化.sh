echo "*************************************************";
echo "*  NAME    : xnyh.sh                           *";
echo "*  SUBJECT : 性能优化                           *";
echo "*  DATE    : 2019-08-26                         *";
echo "*  AUTHOR  : zp                                 *";
echo "*************************************************";

####设置东八区####
#cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
####history命令相关####
sed -i 's/HISTSIZE=[0-9]\+/HISTSIZE=9999/g' /etc/profile
source /etc/profile
sed -i "N;10 a export HISTTIMEFORMAT=\'%F %T\'" /root/.bash_profile
source /root/.bash_profile
####linux文件打开数（重新登录后生效）####
sed -i 'N;42 a * - nofile 65536' /etc/security/limits.conf



