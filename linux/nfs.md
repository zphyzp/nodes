# 异机NFS远程mount文件系统实例

共享服务端（1.163）的/data/apache-xxxx/logs/trlogs/ 到客户端的/data/apache-xxxx/logs/trlogs163/文件下 
192.168.1.163（服务端）
192.168.1.164（客户端）

配置服务端
安装NFS程序
yum -y install nfs*
rpcbind,在centos6以前自带的yum源中为portmap。
使用yum安装nfs时会下载依赖，因此只要下载nfs即可，无需再下载rpcbind.

查看是否安装了nfs与rpcbind
rpm -qa |grep nfs
rpm -qa |grep rpcbind

配置/etc/exports（本机地址192.168.1.163）
vim /etc/exports
/data/apache-xxxx/logs/trlogs 192.168.1.164(rw,no_root_squash,no_all_squash,sync)


配置详解
/data/apache-xxxx/logs/trlogs     192.168.1.164        (rw,no_root_squash,no_all_squash,sync)
要共享的目录                      要分享给的客户端     客户端对此共享目录的权限

------------------------------------------------------------------
客户端指定
192.168.1.125           指定特定的的IP可以共享nfs目录
*                       指定所有网段及ip都可以共享nfs目录
192.168.1.0/24          指定子网中的所有主机都可以共享nfs目录
2018fs.wxyonghe.com     指定域名的主机可以共享nfs目录
---------------------------------------------------------------------------
权限
rw                      可读可写     
ro                      只读(还与文件系统的rwx有关)
sync　　                 数据同步写入到内存与硬盘中
async                   数据先暂存于内存当中，不会直接写入硬盘
wdelay                  当有写操作，就会检查是否有相关的写操作，并在一起执行(默认设置)
no_wdelay               当有写操作就立即执行，通常要与sync配合使用
root_squash             当客户端登陆NFS的身份为root用户时，将客户端的root用户及所属组都映射为匿名用户或用户组（默认设置） 
no_root_squash　　       使客户端可以使用root身份及权限来操作共享的目录
all_squash              无论客户端登陆NFS的身份为何，都将映射为匿名用户
no_all_squash           无论客户端登陆NFS的身份为何，都将映射为root用户（默认设置）
anonuid                 将远程访问的所有用户都映射为匿名用户，并指定该用户为本地用户
anongid                 将远程访问的所有用户组都映射为匿名用户组账户，并指定该匿名用户组账户为本地用户组账户
secure                  使客户端只能从小于1024的tcp/ip端口连接服务端(默认设置)
insecure                允许客户端从大于1024的tcp/ip端口连接服务端
subtree                 当共享的目录是一个子目录，服务端会检查其父目录的权限(默认设置)
no_subtree              当共享的目录是一个子目录，服务端不检查其父目录的权限


设置固定端口：
vi /etc/sysconfig/nfs 文件：
最底部添加如下内容：
RQUOTAD_PORT=30001
LOCKD_TCPPORT=30002
LOCKD_UDPPORT=30002
MOUNTD_PORT=30003
STATD_PORT=30004

添加后保存退出并重启rpcbind和nfs（注意启动服务的先后顺序）
1，service rpcbind  restart
2，service nfs restart

设为开机自启
chkconfig nfs on
chkconfig rpcbind on

rpcinfo -p查看固定端口配置

根据实际情况修改防火墙策略
vi /etc/sysconfig/iptables
填加如下内容（容许192.168.1.164（客户端）访问本机的111,2049,30001-30004端口）
-A INPUT -m state --state NEW -m tcp -p tcp -s 192.168.1.164 --dport 111 -j ACCEPT     ####nfs的默认端口###
-A INPUT -m state --state NEW -m udp -p udp -s 192.168.1.164 --dport 111 -j ACCEPT     ####nfs的默认端口###
-A INPUT -m state --state NEW -m tcp -p tcp -s 192.168.1.164 --dport 2049 -j ACCEPT    ####nfs的默认端口###
-A INPUT -m state --state NEW -m udp -p udp -s 192.168.1.164 --dport 2049 -j ACCEPT    ####nfs的默认端口###
-A INPUT -m state --state NEW -m tcp -p tcp -s 192.168.1.164 --dport 30001:30004 -j ACCEPT    ###刚才配置的固定端口###
-A INPUT -m state --state NEW -m udp -p udp -s 192.168.1.164 --dport 30001:30004 -j ACCEPT    ###刚才配置的固定端口###

service iptables restart重启防火墙

查看本地共享
showmount -e localhost
Export list for localhost:
/data/apache-2.4.39/logs/trlog 192.168.1.163

配置客户端（若是两台机器互相共享互为服务端，则需要再按如上方式配置本机，若不是，则继续）
service rpcbind  restart
service nfs restart

设为开机自启
chkconfig nfs on
chkconfig rpcbind on

[root@bjgtjnew ~]# showmount -e 192.168.1.163
Export list for 192.168.1.163:
/data/apache-2.4.39/logs/trlog 192.168.1.164

挂载服务端目录达成共享
mount -t nfs -o nolock 192.168.1.163:/data/apache-2.4.39/logs/trlog /data/apache-2.4.39/logs/trlog163

df -h确认