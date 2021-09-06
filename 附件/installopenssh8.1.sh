#!/bin/sh
#yum install vnc* -y
#vncserver
#passwd
#密码为：hanweb@123QWE
#Verify
#
#vncpasswd重置密码

####关闭防火墙####
service iptables stop

####卸载openssh并安装zlib####
rpm -e `rpm -qa | grep openssh` --nodeps
rm -rf /etc/init.d/sshd
cd /data/soft
tar -zxvf zlib-1.2.11.tar.gz
chmod -R 750 zlib-1.2.11
cd zlib-1.2.11 
./configure 
make&&make install 

####更新openssl####
cd ../
tar -zxvf openssl-1.1.1d.tar.gz 
chmod -R 750 openssl-1.1.1d
cd openssl-1.1.1d
./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib 
make&&make install
echo "pathmunge /usr/local/openssl/bin" >> /etc/profile.d/openssl.sh
echo "/usr/local/openssl/lib " >> /etc/ld.so/conf.d/openssl-1.1.conf
ldconfig -v
rm /usr/bin/openssl
ln -s /usr/local/bin/openssl /usr/bin/openssl

####更新openssh####
mv/etc/ssh /etc/bak_ssh 
cd ../
tar -zxvf openssh-8.1p1.tar.gz 
chmod -R 750 openssh-8.1p1
cd openssh-8.1p1
./configure --prefix=/usr --sysconfdir=/etc/ssh  --with-zlib --with-ssl-dir=/usr/local/openssl --with-md5-passwords --mandir=/usr/share/man
make&&make install
cp contrib/redhat/sshd.init /etc/init.d/sshd
#echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
rm -rf /root/.ssh/known_hosts

#在vncserver内执行
service sshd restart
service iptables start
#关闭vncserver
#vncserver -kill :1

