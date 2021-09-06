echo "*************************************************";
echo "*  NAME    : safe3.sh                           *";
echo "*  SUBJECT : 等保三级                           *";
echo "*  DATE    : 2019-08-21                         *";
echo "*  AUTHOR  : zp                                 *";
echo "*************************************************";

####密码规则####
sed -i 's/try_first_pass retry=3 type=/difok=3 minlen=8 ucredit=-1 lcredit=-1 dcredit=1/g' /etc/pam.d/system-auth
####密码修改时间####
sed -i 's/PASS_MAX_DAYS\t[0-9]\+/PASS_MAX_DAYS\t90/g' /etc/login.defs
sed -i 's/PASS_MIN_DAYS\t[0-9]\+/PASS_MIN_DAYS\t0/g' /etc/login.defs
sed -i 's/PASS_WARN_AGE\t[0-9]\+/PASS_WARN_AGE\t7/g' /etc/login.defs
####账号锁定####
sed 'N;6 a auth        required      pam_tally.so onerr=fail deny=10 unlock_time=300' -i /etc/pam.d/system-auth
####重要目录权限设置####
#chmod 750 /etc/
#chmod -R 750 /etc/rc.d/init.d/
#chmod -R 777 /tmp
#chmod 750 /etc/inetd.conf
#chmod 750 /etc/passwd
#chmod 750 /etc/shadow
#chmod 750 /etc/group
#chmod 750 /etc/security
#chmod 750 /etc/services
#chmod 750/etc/rc*.d
####开启系统日志####
cat >> /etc/syslog.conf <<EOF
kern.warning;*.err;authpriv.none\t@loghost
*.info;mail.none;authpriv.none;cron.none\t@loghost
*.emerg\t@loghost
local7.*\t@loghost
EOF
####关闭core dump####
sed -i 's/\#\*               soft/\*                soft/g' /etc/security/limits.conf
sed -e "/1/a \*                hard    core            0" -i /etc/security/limits.conf
####设置umask####
sed -i 's/umask [0-9]\+/umask 027/g' /etc/profile
sed -i 's/umask [0-9]\+/umask 027/g' /etc/bashrc
sed -i 's/umask [0-9]\+/umask 027/g' /etc/csh.cshrc

echo "已完成"
