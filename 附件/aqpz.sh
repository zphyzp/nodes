####修改用户shell域为/bin/false####
usermod -s /bin/false lp
usermod -s /bin/false sync
usermod -s /bin/false halt
usermod -s /bin/false news
usermod -s /bin/false uucp
usermod -s /bin/false operator
usermod -s /bin/false games
usermod -s /bin/false gopher
usermod -s /bin/false smmsp
usermod -s /bin/false nfsnobody 
usermod -s /bin/false nobody

####口令锁定策略####
sed 'N;6 a auth        required      pam_tally2.so deny=5 unlock_time=300 even_deny_root root_unlock_time=10' -i /etc/pam.d/system-auth
sed 'N;10 a account     required      pam_tally2.so' -i /etc/pam.d/system-auth

####口令复杂度####
sed -i 's/dcredit=-1/dcredit=-1 ocredit=-1/g' /etc/pam.d/system-auth

####口令重复次数限制####
sed -i 's/use_authtok/use_authtok remember=5/g' /etc/pam.d/system-auth

####使用PAM认证模块禁止wheel组之外的用户su为root####
sed 'N;4 a auth        sufficient    pam_rootok.so' -i /etc/pam.d/system-auth
sed 'N;4 a auth        required      pam_wheel.so use_uid' -i /etc/pam.d/system-auth

####使用SSH协议进行远程维护####
sed -i '0,/no/s/no/yes/' /etc/xinetd.d/telnet
service xinetd restart

####修改SSH的Banner信息####
echo " Authorized users only. All activity may be monitored and reported " > /etc/motd
touch /etc/ssh_banner
chown bin:bin /etc/ssh_banner
chmod 644 /etc/ssh_banner
echo "Authorized only. All activity will be monitored and reported" > /etc/ssh_banner
echo "Banner /etc/ssh_banner" >> /etc/ssh/sshd_config

###配置NFS服务限制####
echo "nfs:192.168.1.*:allow" >> /etc/hosts.allow
echo "nfs:all" >> /etc/hosts.deny


####控制远程访问的IP地址####
echo "sshd:192.168.1.*:allow" >> /etc/hosts.allow
echo "sshd:all" >> /etc/hosts.deny

####配置NTP####
echo "server 192.168.1.44" >> /etc/ntp.conf

####口令生存期####
sed -i 's/PASS_MAX_DAYS\t[0-9]\+/PASS_MAX_DAYS\t90/g' /etc/login.defs
sed -i 's/PASS_MIN_DAYS\t[0-9]\+/PASS_MIN_DAYS\t10/g' /etc/login.defs
sed -i 's/PASS_WARN_AGE\t[0-9]\+/PASS_WARN_AGE\t7/g' /etc/login.defs

####文件与目录缺省权限控制####
sed -i 's/umask [0-9]\+/umask 027/g' /etc/profile
source  /etc/profile

####账号文件权限设置####
chmod 644 /etc/passwd
chmod 400 /etc/shadow
chmod 644 /etc/group

####配置用户最小授权####
chmod 644 /etc/services
chmod 600 /etc/xinetd.conf
chmod 600 /etc/security

####对root为ls、rm设置别名####
echo "alias ls='ls -aol' " >> ~/.bashrc
echo "alias rm='rm -i' " >> ~/.bashrc

####禁止ICMP重定向####
echo "net.ipv4.conf.all.accept_redirects=0" >> /etc/sysctl.conf
sysctl  -p

####启用远程日志功能####
echo "*.*  @192.168.1.166" >> /etc/rsyslog.conf

####记录安全事件日志####
echo "*.err;kern.debug;daemon.notice /var/adm/messages" >> /etc/rsyslog.conf
mkdir /var/adm/
touch /var/adm/messages
chmod 666 /var/adm/messages
/etc/init.d/rsyslog restart

####系统core dump状态####
sed -i 's/\#\*               soft/\*                soft/g' /etc/security/limits.conf
sed -e "/1/a \*                hard    core            0" -i /etc/security/limits.conf

####设置屏幕锁定####
gconftool-2 --direct  --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory  --type bool  --set /apps/gnome-screensaver/idle_activation_enabled true
gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory  --type bool  --set /apps/gnome-screensaver/lock_enabled true
gconftool-2 --direct   --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory    --type string   --set /apps/gnome-screensaver/mode blank-only
gconftool-2 --direct  --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory   --type int   --set /apps/gnome-screensaver/idle_delay 15

####设置关键文件的属性####
chattr +a /var/log/messages

####日志文件安全####
chmod 640 /var/log/boot.log

####更改主机解析地址的顺序####
echo "order hosts,bind" >>  /etc/host.conf
echo "multi on" >>  /etc/host.conf
echo "nospoof on" >>  /etc/host.conf

####历史命令设置####
echo "HISTFILESIZE=5" >> /etc/profile
sed -i 's/HISTSIZE=[0-9]\+/HISTSIZE=5/g' /etc/profile
source /etc/profile

####登陆超时时间设置####
cat /etc/profile |grep TMOUT
if [ $? -ne 0 ]
then
echo "TMOUT=300" >> /etc/profile
echo "export TMOUT" >> /etc/profile
else
sed -i 's/TMOUT\=[0-9]\+/TMOUT\=300/g' /etc/profile
fi
