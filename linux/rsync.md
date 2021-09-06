# rsync实现文件实时同步 sersync多目录实时同步配置

## 一.环境描述

测试环境
需求：服务器A与服务器B为主备服务模式，需要保持文件一致性，现采用sersync基于rsync+inotify实现数据实时同步
环境描述：
主服务器172.26.7.50 ，从服务器172.26.7.51
实时同步/home/ 及/download 目录到从服务器

## 二.实施方法

```shell
1.从服务器172.26.7.51 rsync服务搭建
1.1下载软件包至从服务器
下载地址：http://rsync.samba.org/ftp/rsync/src
可根据环境需求下载相应的软件版本，本实验下载版本为rsync-3.1.1.tar.gz
1.2安装软件包
cd /usr/src
wget http://rsync.samba.org/ftp/rsync/src/rsync-3.1.1.tar.gz
解压
tar xf rsync-3.1.1.tar.gz –C /opt/
mv /opt/rsync-3.1.1 /opt/rsync
cd /opt/rsync
./configure
make &&　make install
创建rsyncd.conf文件
vi /etc/rsyncd.conf
uid = root #以root用户运行rsync服务
gid = root #以root用户运行rsync服务
use chroot = no #增加对目录文件软连接的备份
max connections = 1200 #最大连接数
timeout = 800 #超时时间
pid file = /var/run/rsyncd.pid #PID存放位置
lockfile = /var/run/rsyncd.lock #锁文件存放位置
log file = /var/log/rsyncd.log #日志存放位置
[tongbu] #认证模块名
path = /opt/tongbu #同步A服务器的文件路径
ignore errors = yes #忽略无关错误信息
hosts allow = 172.26.7.50 #允许访问IP
hosts deny = *　＃除了172.26.7.50主机外拒绝所有
read only = no#允许上传
write only = no #允许下载
list = yes #允许列出同步目录
auth users = root #同步的用户
secrets file = /etc/rsync.pass #存放用户密码的文件
###########可以配置多个同步模块
[download]
path = /download
ignore errors = yes
hosts allow = 172.26.7.50
hosts deny = *
read only = no
list = yes
auth users = root
secrets file = /etc/rsync.pass
注：/etc/rsync.pass 文件格式为username:password
文件权限必须为600否则服务不正常
hosts allow 定义可为单独IP也可为网段，网段格式为172.26.7.0/24
也可为172.26.7.0/255.255.255.0
创建rsync.pass文件
echo “root:password”>>/etc/rsync.pass
chmod 600 /etc/rsync.pass
1.3启动服务
rsync --daemon –v
echo “rsync --daemon –v”>>/etc/rc.local
开机自启动
2.主服务器172.26.7.50配置
2.1下载软件包
所需软件包为：
rsync-3.1.1.tar.gz inotify-tools-3.14.tar.gz sersync2.5.4_64bit_binary_stable_final.tar.gz
rysnc下载地址：wget http://rsync.samba.org/ftp/rsync/src/rsync-3.1.1.tar.gz
inotify-tools下载：wget http://github.com/downloads/rvoicilas/inotify-tools/inotify-tools-3.14.tar.gz
sersync下载：https://code.google.com/p/sersync/downloads
2.2软件安装
软件下载好之后解压安装
cd /usr/src
wget http://rsync.samba.org/ftp/rsync/src/rsync-3.1.1.tar.gz
wget http://github.com/downloads/rvoicilas/inotify-tools/inotify-tools-3.14.tar.gz
wget https://sersync.googlecode.com/files/sersync2.5.4_64bit_binary_stable_final.tar.gz
解压
tar xf rsync-3.1.1.tar.gz –C /opt
tar xf inotify-tools-3.14.tar.gz –C /opt
tar xf sersync2.5.4_64bit_binary_stable_final.tar.gz–C /opt
cd /opt
mv rsync-3.1.1 rsync
mv inotify-tools-3.14inotify-tools
mv GNU-Linux-x86 sersync
编译安装rsync
cd rsync
./configure && make && make install
编译安装inotify-tools
cd inotify-tools
./configure && make && make install
2.3服务配置
配置sersync
cd sersync
cp confxml.xml confxml.xml_bak
vi confxml.xml
<?xml version="1.0"encoding="ISO-8859-1"?>

<head version="2.5">
<host hostip="localhost"port="8008"></host>
<debug start="false"/>
<fileSystem xfs="false"/>
<filter start="false">
<exclude expression="(.*)\.svn"></exclude>
<exclude expression="(.*)\.gz"></exclude>
<exclude expression="^info/*"></exclude>
<exclude expression="^static/*"></exclude>
</filter>
<inotify>
<delete start="true"/>
<createFolder start="true"/>
<createFile start="false"/>
<closeWrite start="true"/>
<moveFrom start="true"/>
<moveTo start="true"/>
<attrib start="false"/>
<modify start="false"/>
</inotify>
<sersync>
<localpath watch="/opt/tongbu"><!—与从服务器同步的文件路径-->
<remote ip="172.26.7.51"name="tongbu"/><!—与从服务器的模块名必须相同-->
</localpath>
<rsync>
<commonParams params="-artuzlpog"/><!—rsync参数设置-->
<auth start="true"users="root" passwordfile="/opt/sersync/user.pass"/>
<userDefinedPort start="false"port="873"/><!-- port=874 -->
<timeout start="false" time="100"/><!--timeout=100 -->
<ssh start="false"/>
</rsync>
<failLogpath="/tmp/rsync_fail_log.sh"timeToExecute="60"/><!--default every 60mins execute once-->
<crontab start="false"schedule="600"><!--600mins-->
<crontabfilter start="false">
<excludeexpression="*.php"></exclude>
<excludeexpression="info/*"></exclude>
</crontabfilter>
</crontab>
<plugin start="false" name="command"/>
</sersync>
</head>

########如果是多个目录同步需要起两个sersync进程同时需要两个启动配置文件
cp /opt/sersync/confxml.xml /opt/sersync/downxml.xml
vi /opt/sersync/downxml.xml
<?xml version="1.0"encoding="ISO-8859-1"?>

<head version="2.5">
<host hostip="localhost"port="8008"></host>
<debug start="false"/>
<fileSystem xfs="false"/>
<filter start="false">
<exclude expression="(.*)\.svn"></exclude>
<exclude expression="(.*)\.gz"></exclude>
<exclude expression="^info/*"></exclude>
<exclude expression="^static/*"></exclude>
</filter>
<inotify>
<delete start="true"/>
<createFolder start="true"/>
<createFile start="false"/>
<closeWrite start="true"/>
<moveFrom start="true"/>
<moveTo start="true"/>
<attrib start="false"/>
<modify start="false"/>
</inotify>
<sersync>
<localpath watch="/download"><!—与从服务器同步的文件路径-->
<remote ip="172.26.7.51"name="download"/><!—与从服务器的模块名必须相同-->
</localpath>
<rsync>
<commonParams params="-artuzlpog"/><!—rsync参数设置-->
<auth start="true"users="root" passwordfile="/opt/sersync/user.pass"/>
<userDefinedPort start="false"port="873"/><!-- port=874 -->
<timeout start="false" time="100"/><!--timeout=100 -->
<ssh start="false"/>
</rsync>
<failLogpath="/tmp/rsync_fail_log.sh"timeToExecute="60"/><!--default every 60mins execute once-->
<crontab start="false"schedule="600"><!--600mins-->
<crontabfilterstart="false">
<excludeexpression="*.php"></exclude>
<excludeexpression="info/*"></exclude>
</crontabfilter>
</crontab>
<plugin start="false" name="command"/>
</sersync>
</head>

配置密码文件
echo “password”>>/opt/sersync/user.pass
注：文件权限必须为600否则启动异常
2.4服务启动
nohup /opt/sersync/sersync2 -r -d -o/opt/sersync/confxml.xml >/opt/sersync/rsync.log 2>&1 &
#######如果是多个目录同步需要启动两个进程
nohup /opt/sersync/sersync2 -r -d -o/opt/sersync/downxml.xml >/opt/sersync/downrsync.log 2>&1 &
-d:启用守护进程模式
-r:在监控前，将监控目录与远程主机用rsync命令推送一遍
-n:指定开启守护线程的数量，默认为10个
-o:指定配置文件，默认使用confxml.xml文件
开机启动写入/etc/rc.local文件中
验证
在主服务器上的/opt/tongbu及/home目录下创建文件查看从服务器172.26.7.51上是否有同步
```

# CentOS 6

## 一、rsync 简介

　Rsync（remote synchronize）是一个远程数据同步工具，可通过LAN/WAN快速同步多台主机间的文件，也可以使用 Rsync 同步本地硬盘中的不同目录。
　　Rsync 是用于取代rcp的一个工具，Rsync使用所谓的 “Rsync 算法” 来使本地和远程两个主机之间的文件达到同步，这个算法只传送两个文件的不同部分，而不是每次都整份传送，因此速度相当快。您可以参考 How Rsync Works A Practical Overview 进一步了解 rsync 的运作机制。
　　Rsync支持大多数的类Unix系统，无论是Linux、Solaris还是BSD上都经过了良好的测试。此外，它在windows平台下也有相应的版本，比较知名的有cwRsync和Sync2NAS。
　　Rsync 的初始作者是 Andrew Tridgell 和 Paul Mackerras，它当前由 http://rsync.samba.org维护。
　　Rsync的基本特点如下：

  　　1. 可以镜像保存整个目录树和文件系统；
    　　2. 可以很容易做到保持原来文件的权限、时间、软硬链接等；
      　　3. 无须特殊权限即可安装；
        　　4. 优化的流程，文件传输效率高；
          　　5. 可以使用rcp、ssh等方式来传输文件，当然也可以通过直接的socket连接；
            　　6. 支持匿名传输，以方便进行网站镜像。
       在使用 rsync 进行远程同步时，可以使用两种方式：远程 Shell 方式（建议使用 ssh，用户验证由 ssh 负责）和 C/S 方式（即客户连接远程 rsync 服务器，用户验证由 rsync 服务器负责）。
       　　无论本地同步目录还是远程同步数据，首次运行时将会把全部文件拷贝一次，以后再运行时将只拷贝有变化的文件（对于新文件）或文件的变化部分（对于原有文件）。
       　　rsync 在首次复制时没有速度优势，速度不如 tar，因此当数据量很大时您可以考虑先使用 tar 进行首次复制，然后再使用 rsync 进行数据同步。



##      二、系统环境

```shell

       系统平台：CentOS release 6.3 (Final)
       rsync 版本：rsync-3.0.9-2.el6.rfx.x86_64.rpm
       rsync 服务器：TS-DEV （172.16.1.135）
       rsync 客户端：TS-CLIENT （172.16.1.136）
       三、服务器端安装rsync服务
       3.1. 检查rsync 是否已经安装

# rpm -qa|grep rsync

若已经安装，则使用rpm -e 命令卸载。
3.2. 下载RPM包

# wget http://pkgs.repoforge.org/rsync/rsync-3.0.9-2.el6.rfx.x86_64.rpm

3.3. 安装rsync

# rpm -ivh rsync-3.0.9-2.el6.rfx.x86_64.rpm

四、配置 rsync 服务
4.1. 配置 rsync 服务器的步骤
首先要选择服务器启动方式
对于负荷较重的 rsync 服务器应该使用独立运行方式
对于负荷较轻的 rsync 服务器可以使用 xinetd 运行方式
创建配置文件 rsyncd.conf
对于非匿名访问的 rsync 服务器还要创建认证口令文件
4.2. 以 xinetd 运行 rsync 服务
CentOS 默认以 xinetd 方式运行 rsync 服务。rsync 的 xinetd 配置文件
在 /etc/xinetd.d/rsync。要配置以 xinetd 运行的 rsync 服务需要执行如下的命令：

# chkconfig rsync on# service xinetd restart

管理员可以修改 /etc/xinetd.d/rsync 配置文件以适合您的需要。例如，您可以修改配置行
server_args = --daemon
在后面添加 rsync 的服务选项。
4.3. 独立运行 rsync 服务
最简单的独立运行 rsync 服务的方法是执行如下的命令：

# /usr/bin/rsync --daemon

您可以将上面的命令写入 /etc/rc.local 文件以便在每次启动服务器时运行 rsync 服务。当然，您也可以写一个脚本在开机时自动启动 rysnc 服务。
4.4. 配置文件 rsyncd.conf
两种 rsync 服务运行方式都需要配置 rsyncd.conf，其格式类似于 samba 的主配置文件。
配置文件 rsyncd.conf 默认在 /etc 目录下。为了将所有与 rsync 服务相关的文件放在单独的目录下，可以执行如下命令：

# mkdir /etc/rsyncd# touch /etc/rsyncd/rsyncd.conf# ln -s /etc/rsyncd/rsyncd.conf /etc/rsyncd.conf

配置文件 rsyncd.conf 由全局配置和若干模块配置组成。配置文件的语法为：
模块以 [模块名] 开始
参数配置行的格式是 name = value ，其中 value 可以有两种数据类型：
字符串（可以不用引号定界字符串）
布尔值（1/0 或 yes/no 或 true/false）
以 # 或 ; 开始的行为注释
\ 为续行符
全局参数
在文件中 [module] 之外的所有配置行都是全局参数。当然也可以在全局参数部分定义模块参数，这时该参数的值就是所有模块的默认值。
参数
说明
默认值
address
在独立运行时，用于指定的服务器运行的 IP 地址。由 xinetd 运行时将忽略此参数，使用命令行上的 –address 选项替代。
本地所有IP
port
指定 rsync 守护进程监听的端口号。 由 xinetd 运行时将忽略此参数，使用命令行上的–port 选项替代。
873
motd file
指定一个消息文件，当客户连接服务器时该文件的内容显示给客户。
无
pid file
rsync 的守护进程将其 PID 写入指定的文件。
无
log file
指定 rsync 守护进程的日志文件，而不将日志发送给 syslog。
无
syslog facility
指定 rsync 发送日志消息给 syslog 时的消息级别。
daemon
socket options
指定自定义 TCP 选项。
无
模块参数
模块参数主要用于定义 rsync 服务器哪个目录要被同步。模块声明的格式必须为 [module] 形式，这个名字就是在 rsync 客户端看到的名字，类似于 Samba 服务器提供的共享名。而服务器真正同步的数据是通过 path 来指定的。可以根据自己的需要，来指定多个模块，模块中可以定义以下参数：
a. 基本模块参数
参数
说明
默认值
path
指定当前模块在 rsync 服务器上的同步路径，该参数是必须指定的。
无
comment
给模块指定一个描述，该描述连同模块名在客户连接得到模块列表时显示给客户。
无
b. 模块控制参数
参数
说明
默认值
use chroot
若为 true，则 rsync 在传输文件之前首先 chroot 到 path 参数所指定的目录下。这样做的原因是实现额外的安全防护，但是缺点是需要 root 权限，并且不能备份指向 path 外部的符号连接所指向的目录文件。
true
uid
指定该模块以指定的 UID 传输文件。
nobody
gid
指定该模块以指定的 GID 传输文件。
nobody
max connections
指定该模块的最大并发连接数量以保护服务器，超过限制的连接请求将被告知随后再试。
0（没有限制）
lock file
指定支持 max connections 参数的锁文件。
/var/run/rsyncd.lock
list
指定当客户请求列出可以使用的模块列表时，该模块是否应该被列出。如果设置该选项为 false，可以创建隐藏的模块。
true
read only
指定是否允许客户上传文件。若为 true 则不允许上传；若为 false 并且服务器目录也具有读写权限则允许上传。
true
write only
指定是否允许客户下载文件。若为 true 则不允许下载；若为 false 并且服务器目录也具有读权限则允许下载。
false
ignore errors
指定在 rsync 服务器上运行 delete 操作时是否忽略 I/O 错误。一般来说 rsync 在出现 I/O 错误时将将跳过 –delete 操作，以防止因为暂时的资源不足或其它 I/O 错误导致的严重问题。
true
ignore nonreadable
指定 rysnc 服务器完全忽略那些用户没有访问权限的文件。这对于在需要备份的目录中有些不应该被备份者获得的文件时是有意义的。
false
timeout
该选项可以覆盖客户指定的 IP 超时时间。从而确保 rsync 服务器不会永远等待一个崩溃的客户端。对于匿名 rsync 服务器来说，理想的数字是 600（单位为秒）。
0 (未限制)
dont compress
用来指定那些在传输之前不进行压缩处理的文件。该选项可以定义一些不允许客户对该模块使用的命令选项列表。必须使用选项全名，而不能是简称。当发生拒绝某个选项的情况时，服务器将报告错误信息然后退出。例如，要防止使用压缩，应该是：”dont compress = *”。
*.gz *.tgz *.zip *.z *.rpm *.deb *.iso *.bz2 *.tbz
c. 模块文件筛选参数
参数
说明
默认值
exclude
指定多个由空格隔开的多个文件或目录(相对路径)，并将其添加到 exclude 列表中。这等同于在客户端命令中使用 –exclude 来指定模式。
空
exclude from
指定一个包含 exclude 规则定义的文件名，服务器从该文件中读取 exclude 列表定义。
空
include
指定多个由空格隔开的多个文件或目录(相对路径)，并将其添加到 include 列表中。这等同于在客户端命令中使用 –include 来指定模式 。
空
include from
指定一个包含 include 规则定义的文件名，服务器从该文件中读取 include 列表定义。
空
一个模块只能指定一个exclude 参数、一个include 参数。
结合 include 和 exclude 可以定义复杂的exclude/include 规则 。
这几个参数分别与相应的rsync 客户命令选项等价，唯一不同的是它们作用在服务器端。
关于如何书写规则文件的内容请参考http://www.howtocn.org/rsync:use_rsync。
d. 模块用户认证参数
参数
说明
默认值
auth users
指定由空格或逗号分隔的用户名列表，只有这些用户才允许连接该模块。这里的用户和系统用户没有任何关系。用户名和口令以明文方式存放在 secrets file 参数指定的文件中。
(匿名方式)
secrets file
指定一个 rsync 认证口令文件。只有在 auth users 被定义时，该文件才起作用。
空
strict modes
指定是否监测口令文件的权限。若为 true 则口令文件只能被 rsync 服务器运行身份的用户访问，其他任何用户不可以访问该文件。
true
rsync 认证口令文件的权限一定是 600，否则客户端将不能连接服务器。
rsync 认证口令文件中每一行指定一个 用户名:口令 对，格式为：
　　　　username:passwd
一般来说口令最好不要超过8个字符。若您只配置匿名访问的 rsync 服务器，则无需设置上述参数。
e. 模块访问控制参数
参数
说明
默认值
hosts allow
用一个主机列表指定哪些主机客户允许连接该模块。不匹配主机列表的主机将被拒绝。
*
hosts deny
用一个主机列表指定哪些主机客户不允许连接该模块。
空
客户主机列表定义可以是以下形式：
单个IP地址。例如：192.168.0.1
整个网段。例如：192.168.0.0/24，192.168.0.0/255.255.255.0
可解析的单个主机名。例如：centos，centos.bsmart.cn
域内的所有主机。例如：*.bsmart.cn
“*”则表示所有。
多个列表项要用空格间隔。
f. 模块日志参数
参数
说明
默认值
transfer logging
使 rsync 服务器将传输操作记录到传输日志文件。
false
log format
指定传输日志文件的字段。
”%o %h [%a] %m (%u) %f %l”
设置了”log file”参数时，在日志每行的开始会添加”%t [%p]“。
可以使用的日志格式定义符如下所示：
%a - 远程IP地址
%h - 远程主机名
%l - 文件长度字符数
%p - 该次 rsync 会话的 PID
%o - 操作类型：”send” 或 “recv”
%f - 文件名
%P - 模块路径
%m - 模块名
%t - 当前时间
%u - 认证的用户名（匿名时是 null）
%b - 实际传输的字节数
%c - 当发送文件时，记录该文件的校验码
五、rsync 服务器应用案例
5.1. 在服务器端TS-DEV上配置rsync 服务
a. 编辑配置文件

# vi /etc/rsyncd/rsyncd.conf

复制代码

# Minimal configuration file for rsync daemon# See rsync(1) and rsyncd.conf(5) man pages for help# This line is required by the /etc/init.d/rsyncd script

# GLOBAL OPTIONSuid = root gid = root 

use chroot = no 
read only = yes #limit access to private LANshosts allow=172.16.0.0/255.255.0.0 192.168.1.0/255.255.255.0 10.0.1.0/255.255.255.0hosts deny=* 
max connections = 5 

pid file = /var/run/rsyncd.pid 

secrets file = /etc/rsyncd/rsyncd.secrets 
#lock file = /var/run/rsync.lock 
motd file = /etc/rsyncd/rsyncd.motd #This will give you a separate log filelog file = /var/log/rsync.log #This will log every file transferred - up to 85,000+ per user, per synctransfer logging = yes log format = %t %a %m %f %bsyslog facility = local3timeout = 300

# MODULE OPTIONS[davidhome] path = /home/david/ list=yes ignore errors auth users = david comment = David home exclude = important/ [chinatmp]path = /tmp/china/list=noignore errorsauth users = chinacomment = tmp_china

复制代码
b. 建立/etc/rsyncd/rsyncd.secrets文件

# vim /etc/rsyncd/rsyncd.secrets

david:asdf #格式 用户名:口令
china:jk #该用户不要求是系统用户
c. 为了密码的安全性，我们把权限设为600

# chown root:root /etc/rsyncd/rsyncd.secrets

# chmod 600 /etc/rsyncd/rsyncd.secrets

d. 建立连接到服务器的客户端看到的欢迎信息文件/etc/rsyncd/rsyncd.motd

# vim /etc/rsyncd/rsyncd.motd

+++++++++++++++++++++++++++

+ David Camp +

+++++++++++++++++++++++++++

e. 启动rsync

# /etc/init.d/xinetd restart

f. 查看873端口是否起来

# netstat -an | grep 873

如果rsync启动成功的话可以看到873端口已经在监听了。
g. 服务器端文件详细

5.2. 客户端配置
a. 客户端安装rsync

# yum -y install rsync

b. 通过rsync客户端来同步数据
场景一：

# rsync -avzP david@172.16.1.135::davidhome /tmp/david/

Password: 这里要输入david的密码，是服务器端提供的，在前面的例子中，我们用的是 asdf，输入的密码并不显示出来；输好后就回车；
注： 这个命令的意思就是说，用david 用户登录到服务器上，把davidhome数据，同步到本地目录/tmp/david/上。当然本地的目录是可以你自己定义的，比如 dave也是可以的；当你在客户端上，当前操作的目录下没有davidhome这个目录时，系统会自动为你创建一个；当存在davidhome这个目录中，你要注意它的写权限。
说明：
-a 参数，相当于-rlptgoD，-r 是递归 -l 是链接文件，意思是拷贝链接文件；-p 表示保持文件原有权限；-t 保持文件原有时间；-g 保持文件原有用户组；-o 保持文件原有属主；-D 相当于块设备文件；
-z 传输时压缩；
-P 传输进度；
-v 传输时的进度等信息，和-P有点关系，自己试试。可以看文档；
场景二：

# rsync -avzP --delete david@172.16.1.135::davidhome /tmp/david/

这回我们引入一个 –delete 选项，表示客户端上的数据要与服务器端完全一致，如果 /tmp/david/目录中有服务器上不存在的文件，则删除。最终目的是让/tmp/david/目录上的数据完全与服务器上保持一致；用的时候要小心点，最好不要把已经有重要数所据的目录，当做本地更新目录，否则会把你的数据全部删除；
场景三：

# rsync -avzP --delete --password-file=/tmp/rsync.password david@172.16.1.135::davidhome /tmp/david/

这次我们加了一个选项 –password-file=rsync.password ，这时当我们以david用户登录rsync服务器同步数据时，密码将读取 /tmp/rsync.password 这个文件。这个文件内容只是david用户的密码。我们要如下做；

# touch /tmp/rsync.password

# chmod 600 /tmp/rsync.password

# echo "asdf"> /tmp/rsync.password

# rsync -avzP --delete --password-file=/tmp/rsync.password david@172.16.1.135::davidhome /tmp/david/

注： 这样就不需要密码了；其实这是比较重要的，因为服务器通过crond 计划任务还是有必要的；
5.3. rsync 客户端自动与服务器同步数据
编辑crontab

# crontab -e

加入如下代码：
10 0 * * * rsync -avzP --delete --password-file=/tmp/rsync.password david@172.16.1.135::davidhome /tmp/david/
表示每天0点10分执行后面的命令。
六、错误分析
@ERROR: chdir failed 
rsync error: error starting client-server protocol (code 5) at main.c(1530) [receiver=3.0.6] 

rsync: opendir "." (in xxxxxxx) failed: Permission denied (13)

解决办法：
1、将 selinux 对 rsync 的限制全部去掉：

# /usr/sbin/setsebool -P rsync_disable_trans 1

# service xinetd restart

2、狠一点，禁止整个 selinux ：

# vim /etc/selinux/config

将其中的 SELINUX=enforcing 修改为 SELINUX=disabled
保存退出后，重启机器。
至此，rsync服务器配置完毕。
七、参考
关于rsync 命令的使用，请参考：http://www.howtocn.org/rsync:use_rsync
关于rsync 服务的详细说明，请参考：http://www.howtocn.org/rsync:use_rsync_server
```

# RSync实现文件备份同步

```sehll
一、什么是rsync
　　rsync，remotesynchronize顾名思意就知道它是一款实现远程同步功能的软件，它在同步文件的同时，可以保持原来文件的权限、时间、软硬链接等附加信息。rsync是用 “rsync算法”提供了一个客户机和远程文件服务器的文件同步的快速方法，而且可以通过ssh方式来传输文件，这样其保密性也非常好，另外它还是免费的软件。
　　rsync 包括如下的一些特性：
　　能更新整个目录和树和文件系统；
　　有选择性的保持符号链链、硬链接、文件属于、权限、设备以及时间等；
　　对于安装来说，无任何特殊权限要求；
　　对于多个文件来说，内部流水线减少文件等待的延时；
　　能用rsh、ssh 或直接端口做为传输入端口；
　　支持匿名rsync 同步文件，是理想的镜像工具；
二、架设rsync服务器
　　架设rsync 服务器比较简单，写一个配置文件rsyncd.conf 。文件的书写也是有规则的，我们可以参照rsync.samba.org 上的文档来做。当然我们首先要安装好rsync这个软件才行；
A、rsync的安装；
　　获取rsync
　　rysnc的官方网站：http://rsync.samba.org/可以从上面得到最新的版本。目前最新版是3.05。当然，因为rsync是一款如此有用的软件，所以很多Linux的发行版本都将它收录在内了。
　　软件包安装
　　# sudo apt-get install rsync 注：在debian、ubuntu 等在线安装方法；
　　# yum install rsync 注：Fedora、Redhat 等在线安装方法；
　　# rpm -ivh rsync 注：Fedora、Redhat 等rpm包安装方法；
　　其它Linux发行版，请用相应的软件包管理方法来安装。
　　源码包安装
　　tar xvf rsync-xxx.tar.gz
　　cd rsync-xxx
　　./configure --prefix=/usr ;make ;make install 注：在用源码包编译安装之前，您得安装gcc等编译开具才行；

B、配置文件
　　rsync的主要有以下三个配置文件rsyncd.conf(主配置文件)、rsyncd.secrets(密码文件)、rsyncd.motd(rysnc服务器信息)
　　服务器配置文件(/etc/rsyncd.conf)，该文件默认不存在，请创建它。
　　具体步骤如下：
　　#touch /etc/rsyncd.conf #创建rsyncd.conf，这是rsync服务器的配置文件。
　　#touch /etc/rsyncd.secrets #创建rsyncd.secrets ，这是用户密码文件。
　　#chmod 600 /etc/rsyncd/rsyncd.secrets #将rsyncd.secrets这个密码文件的文件属性设为root拥有, 且权限要设为600, 否则无法备份成功!
　　#touch /etc/rsyncd.motd
　　下一就是我们修改rsyncd.conf和rsyncd.secrets和rsyncd.motd文件的时候了。
　　设定/etc/rsyncd.conf
　　rsyncd.conf是rsync服务器主要配置文件。我们先来个简单的示例，后面在详细说明各项作用。
　　比如我们要备份服务器上的/home和/opt，在/home中我想把easylife和samba目录排除在外；
　　# Distributed under the terms of the GNU General Public License v2
　　# Minimal configuration file for rsync daemon
　　# See rsync(1) and rsyncd.conf(5) man pages for help
　　# This line is required by the /etc/init.d/rsyncd script
　　pid file = /var/run/rsyncd.pid 
　　port = 873
　　address = 192.168.1.171 
　　#uid = nobody
　　#gid = nobody 
　　uid = root 
　　gid = root 
　　use chroot = yes 
　　read only = yes 
　　#limit access to private LANs
　　hosts allow=192.168.1.0/255.255.255.0 10.0.1.0/255.255.255.0 
　　hosts deny=*
　　max connections = 5
　　motd file = /etc/rsyncd.motd
　　#This will give you a separate log file
　　#log file = /var/log/rsync.log
　　#This will log every file transferred - up to 85,000+ per user, per sync
　　#transfer logging = yes
　　log format = %t %a %m %f %b
　　syslog facility = local3
　　timeout = 300
　　[rhel4home] 
　　path = /home 
　　list=yes
　　ignore errors
　　auth users = root
　　secrets file = /etc/rsyncd.secrets 
　　comment = This is RHEL 4 data 
　　exclude = easylife/ samba/ 
　　[rhel4opt]
　　path = /opt
　　list=no
　　ignore errors
　　comment = This is RHEL 4 opt
　　auth users = easylife
　　secrets file = /etc/rsyncd/rsyncd.secrets
　　注：关于auth users是必须在服务器上存在的真实的系统用户，如果你想用多个用户以,号隔开，比如auth users = easylife,root
　　设定密码文件
　　密码文件格式很简单，rsyncd.secrets的内容格式为：
　　用户名:密码
　　我们在例子中rsyncd.secrets的内容如下类似的；在文档中说，有些系统不支持长密码，自己尝试着设置一下吧。
　　easylife:keer
　　root:mike
　　chown root.root rsyncd.secrets 　#修改属主
　　chmod 600 rsyncd.secrets #修改权限
　　注：1、将rsyncd.secrets这个密码文件的文件属性设为root拥有, 且权限要设为600, 否则无法备份成功! 出于安全目的，文件的属性必需是只有属主可读。
　　　　2、这里的密码值得注意，为了安全你不能把系统用户的密码写在这里。比如你的系统用户easylife密码是000000，为了安全你可以让rsync中的easylife为keer。这和samba的用户认证的密码原理是差不多的。
　　设定rsyncd.motd 文件;
　　它是定义rysnc服务器信息的，也就是用户登录信息。比如让用户知道这个服务器是谁提供的等；类似ftp服务器登录时，我们所看到的linuxsir.org ftp ……。 当然这在全局定义变量时，并不是必须的，你可以用#号注掉，或删除；我在这里写了一个rsyncd.motd的内容为：
　　++++++++++++++++++++++++++++++++++++++++++++++
　　Welcome to use the mike.org.cn rsync services!
2002------2009
　　++++++++++++++++++++++++++++++++++++++++++++++
三、rsyncd.conf服务器的配置详解
A、全局定义
　　在rsync 服务器中，全局定义有几个比较关健的，根据我们前面所给的配置文件 rsyncd.conf 文件；
　　pid file = /var/run/rsyncd.pid 注：告诉进程写到 /var/run/rsyncd.pid 文件中；
　　port = 873 注：指定运行端口，默认是873，您可以自己指定；
　　address = 192.168.1.171 注：指定服务器IP地址
　　uid = nobody 
　　gid = nobdoy 
　　注：服务器端传输文件时，要发哪个用户和用户组来执行，默认是nobody。 如果用nobody用户和用户组，可能遇到权限问题，有些文件从服务器上拉不下来。所以我就偷懒，为了方便，用了root。不过您可以在定义要同步的目录时定义的模块中指定用户来解决权限的问题。
　　use chroot = yes 
　　注：用chroot，在传输文件之前，服务器守护程序在将chroot到文件系统中的目录中，这样做的好处是可能保护系统被安装漏洞侵袭的可能。缺点是需要超级用户权限。另外对符号链接文件，将会排除在外。也就是说，你在rsync服务器上，如果有符号链接，你在备份服务器上运行客户端的同步数据时，只会把符号链接名同步下来，并不会同步符号链接的内容；这个需要自己来尝试
　　read only = yes 
　　注：read only 是只读选择，也就是说，不让客户端上传文件到服务器上。还有一个 write only选项，自己尝试是做什么用的吧；
　　#limit access to private LANs
　　hosts allow=192.168.1.0/255.255.255.0 10.0.1.0/255.255.255.0 
　　注：在您可以指定单个IP，也可以指定整个网段，能提高安全性。格式是ip 与ip 之间、ip和网段之间、网段和网段之间要用空格隔开；
　　max connections = 5 
　　注：客户端最多连接数
　　motd file = /etc/rsyncd/rsyncd.motd
　　注：motd file 是定义服务器信息的，要自己写 rsyncd.motd 文件内容。当用户登录时会看到这个信息。比如我写的是：
　　++++++++++++++++++++++++++++++++++++++++++++++
　　Welcome to use the mike.org.cn rsync services!
2002------2009
　　++++++++++++++++++++++++++++++++++++++++++++++
　　log file = /var/log/rsync.log
　　注：rsync 服务器的日志；
　　transfer logging = yes
　　注：这是传输文件的日志
　　log format = %t %a %m %f %b
　　syslog facility = local3
　　timeout = 300
B、模块定义
　　模块定义什么呢？主要是定义服务器哪个目录要被同步。每个模块都要以[name]形式。这个名字就是在rsync客户端看到的名字，其实有点象Samba服务器提供的共享名。而服务器真正同步的数据是通过path指定的。我们可以根据自己的需要，来指定多个模块。每个模块要指定认证用户，密码文件、但排除并不是必须的
　　下面是前面配置文件模块的例子：
　　[rhel4home] #模块它为我们提供了一个链接的名字，在本模块中链接到了/home目录；要用[name] 形式
　　path = /home #指定文件目录所在位置，这是必须指定的
　　auth users = root #认证用户是root ，是必须在服务器上存在的用户
　　list=yes #list 意思是把rsync 服务器上提供同步数据的目录在服务器上模块是否显示列出来。默认是yes 。如果你不想列出来，就no ；如果是no是比较安全的，至少别人不知道你的服务器上提供了哪些目录。你自己知道就行了；
　　ignore errors #忽略IO错误
　　secrets file = /etc/rsyncd.secrets #密码存在哪个文件
　　comment = linuxsir home data #注释可以自己定义
　　exclude = beinan/ samba/ 
　　注：exclude是排除的意思，也就是说，要把/home目录下的easylife和samba排除在外； easylife/和samba/目录之间有空格分开
　　[rhel4opt] 
　　path = /opt
　　list=no
　　comment = optdir 
　　auth users = beinan 
　　secrets file = /etc/rsyncd/rsyncd.secrets
　　ignore errors
四、启动rsync服务器及防火墙的设置
　　启动rsync服务器相当简单，有以下几种方法
　　A、--daemon参数方式，是让rsync以服务器模式运行
　　#/usr/bin/rsync --daemon --config=/etc/rsyncd/rsyncd.conf 　#--config用于指定rsyncd.conf的位置,如果在/etc下可以不写
　　B、xinetd方式
　　修改services加入如下内容
　　# nano -w /etc/services
　　rsync　　873/tcp　　# rsync
　　rsync　　873/udp　　# rsync
　　这一步一般可以不做，通常都有这两行(我的RHEL4和GENTOO默认都有)。修改的目的是让系统知道873端口对应的服务名为rsync。如没有的话就自行加入。
　　设定 /etc/xinetd.d/rsync, 简单例子如下:
　　# default: off
　　# description: The rsync server is a good addition to am ftp server, as it \
　　# allows crc checksumming etc.
　　service rsync
　　{
disable = no
socket_type = stream
wait = no
user = root
server = /usr/bin/rsync
server_args = --daemon
log_on_failure += USERID
　　}
　　上述, 主要是要打开rsync這個daemon, 一旦有rsync client要连接時, xinetd会把它转介給 rsyncd(port 873)。然后service xinetd restart, 使上述设定生效.
　　rsync服务器和防火墙
　　Linux 防火墙是用iptables，所以我们至少在服务器端要让你所定义的rsync 服务器端口通过，客户端上也应该让通过。
　　#iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 873 -j ACCEPT
　　#iptables -L 查看一下防火墙是不是打开了 873端口
　　如果你不太懂防火墙的配置，可以先service iptables stop 将防火墙关掉。当然在生产环境这是很危险的，做实验才可以这么做哟！
五、通过rsync客户端来同步数据
A、语法详解

　　在配置完rsync服务器后，就可以从客户端发出rsync命令来实现各种同步的操作。rsync有很多功能选项，下面就对介绍一下常用的选项：
　　rsync的命令格式可以为：

　　1. rsync [OPTION]... SRC [SRC]... [USER@]HOST:DEST
　　2. rsync [OPTION]... [USER@]HOST:SRC DEST
　　3. rsync [OPTION]... SRC [SRC]... DEST
　　4. rsync [OPTION]... [USER@]HOST::SRC [DEST]
　　5. rsync [OPTION]... SRC [SRC]... [USER@]HOST::DEST
　　6. rsync [OPTION]... rsync://[USER@]HOST[:PORT]/SRC [DEST]
　　rsync有六种不同的工作模式：
　　1. 拷贝本地文件；当SRC和DES路径信息都不包含有单个冒号":"分隔符时就启动这种工作模式。
　　2.使用一个远程shell程序（如rsh、ssh）来实现将本地机器的内容拷贝到远程机器。当DST路径地址包含单个冒号":"分隔符时启动该模式。
　　3.使用一个远程shell程序（如rsh、ssh）来实现将远程机器的内容拷贝到本地机器。当SRC地址路径包含单个冒号":"分隔符时启动该模式。
　　4. 从远程rsync服务器中拷贝文件到本地机。当SRC路径信息包含"::"分隔符时启动该模式。
　　5. 从本地机器拷贝文件到远程rsync服务器中。当DST路径信息包含"::"分隔符时启动该模式。
　　6. 列远程机的文件列表。这类似于rsync传输，不过只要在命令中省略掉本地机信息即可。
　　-a 以archive模式操作、复制目录、符号连接 相当于-rlptgoD
　　rsync中的参数
　　-r 是递归
　　-l 是链接文件，意思是拷贝链接文件；-p 表示保持文件原有权限；-t 保持文件原有时间；-g 保持文件原有用户组；-o 保持文件原有属主；-D 相当于块设备文件；
　　-z 传输时压缩；
　　-P 传输进度；
　　-v 传输时的进度等信息，和-P有点关系，自己试试。可以看文档；
　　-e ssh的参数建立起加密的连接。
　　-u只进行更新，防止本地新文件被重写，注意两者机器的时钟的同时
　　--progress是指显示出详细的进度情况
　　--delete是指如果服务器端删除了这一文件，那么客户端也相应把文件删除，保持真正的一致
　　--password-file=/password/path/file来指定密码文件，这样就可以在脚本中使用而无需交互式地输入验证密码了，这里需要注意的是这份密码文件权限属性要设得只有属主可读。
B、一些实例
　　B1、列出rsync 服务器上的所提供的同步内容；
　　首先：我们看看rsync服务器上提供了哪些可用的数据源
　　# rsync --list-only root@192.168.145.5::
　　++++++++++++++++++++++++++++++++++++++++++++++
　　Welcome to use the mike.org.cn rsync services!
　　 2002------2009
　　++++++++++++++++++++++++++++++++++++++++++++++
　　rhel4home This is RHEL 4 data
　　注：前面是rsync所提供的数据源，也就是我们在rsyncd.conf中所写的[rhel4home]模块。而“This is RHEL 4data”是由[rhel4home]模块中的 comment = This is RHEL 4 data提供的；为什么没有把rhel4opt数据源列出来呢？因为我们在[rhel4opt]中已经把list=no了。
　　$ rsync --list-only root@192.168.145.5::::rhel4home
　　++++++++++++++++++++++++++++++++++++++++++++++
　　Welcome to use the mike.org.cn rsync services!
　　 2002------2009
　　++++++++++++++++++++++++++++++++++++++++++++++
　　Password:
　　drwxr-xr-x 4096 2009/03/15 21:33:13 .
　　-rw-r--r-- 1018 2009/03/02 02:33:41 ks.cfg
　　-rwxr-xr-x 21288 2009/03/15 21:33:13 wgetpaste
　　drwxrwxr-x 4096 2008/10/28 21:04:05 cvsroot
　　drwx------ 4096 2008/11/30 16:30:58 easylife
　　drwsr-sr-x 4096 2008/09/20 22:18:05 giddir
　　drwx------ 4096 2008/09/29 14:18:46 quser1
　　drwx------ 4096 2008/09/27 14:38:12 quser2
　　drwx------ 4096 2008/11/14 06:10:19 test
　　drwx------ 4096 2008/09/22 16:50:37 vbird1
　　drwx------ 4096 2008/09/19 15:28:45 vbird2
　　后面的root@ip中，root是指定密码文件中的用户名，之后的::rhel4home这是rhel4home模块名
　　B2、rsync客户端同步数据；
　　#rsync -avzP root@192.168.145.5::rhel4home rhel4home
　　Password: 这里要输入root的密码，是服务器端rsyncd.secrets提供的。在前面的例子中我们用的是mike，输入的密码并不回显，输好就回车。
　　注：这个命令的意思就是说，用root用户登录到服务器上，把rhel4home数据，同步到本地当前目录rhel4home上。当然本地的目录是可以你自己定义的。如果当你在客户端上当前操作的目录下没有rhel4home这个目录时，系统会自动为你创建一个；当存在rhel4home这个目录中，你要注意它的写权限。
　　#rsync -avzP --delete linuxsir@linuxsir.org::rhel4home rhel4home
　　这回我们引入一个--delete 选项，表示客户端上的数据要与服务器端完全一致，如果linuxsirhome目录中有服务器上不存在的文件，则删除。最终目的是让linuxsirhome目录上的数据完全与服务器上保持一致；用的时候要小心点，最好不要把已经有重要数所据的目录，当做本地更新目录，否则会把你的数据全部删除；
　　設定 rsync client
　　设定密码文件
　　#rsync -avzP --delete --password-file=rsyncd.secrets root@192.168.145.5::rhel4home rhel4home
　　这次我们加了一个选项 --password-file=rsyncd.secrets，这是当我们以root用户登录rsync服务器同步数据时，密码将读取rsyncd.secrets这个文件。这个文件内容只是root用户的密码。我们要如下做；
　　# touch rsyncd.secrets
　　# chmod 600 rsyncd.secrets
　　# echo "mike"> rsyncd.secrets
　　# rsync -avzP --delete --password-file=rsyncd.secrets root@192.168.145.5::rhel4home rhel4home
　　注：这里需要注意的是这份密码文件权限属性要设得只有属主可读。
　　　　这样就不需要密码了；其实这是比较重要的，因为服务器通过crond 计划任务还是有必要的；
　　B3、让rsync客户端自动与服务器同步数据
　　服务器是重量级应用，所以数据的网络备份还是极为重要的。我们可以在生产型服务器上配置好rsync服务器。我们可以把一台装有rysnc机器当做是备份服务器。让这台备份服务器，每天在早上4点开始同步服务器上的数据；并且每个备份都是完整备份。有时硬盘坏掉，或者服务器数据被删除，完整备份还是相当重要的。这种备份相当于每天为服务器的数据做一个镜像，当生产型服务器发生事故时，我们可以轻松恢复数据，能把数据损失降到最低；是不是这么回事？？
　　step1：创建同步脚本和密码文件

　　#mkdir /etc/cron.daily.rsync
　　#cd /etc/cron.daily.rsync
　　#touch rhel4home.sh rhel4opt.sh
　　#chmod 755 /etc/cron.daily.rsync/*.sh 
　　#mkdir /etc/rsyncd/
　　#touch /etc/rsyncd/rsyncrhel4root.secrets
　　#touch /etc/rsyncd/rsyncrhel4easylife.secrets
　　#chmod 600 /etc/rsyncd/rsync.*
　　注： 我们在 /etc/cron.daily/中创建了两个文件rhel4home.sh和rhel4opt.sh，并且是权限是755的。创建了两个密码文件root用户用的是rsyncrhel4root.secrets ，easylife用户用的是rsyncrhel4easylife.secrets，权限是600；
　　我们编辑rhel4home.sh，内容是如下的：
　　#!/bin/sh
　　#backup 192.168.145.5:/home
　　/usr/bin/rsync -avzP --password-file=/etc/rsyncd/rsyncrhel4root.password root@192.168.145.5::rhel4home /home/rhel4homebak/$(date +'%m-%d-%y')
　　我们编辑 rhel4opt.sh ，内容是：
　　#!/bin/sh
　　#backup 192.168.145.5:/opt
　　/usr/bin/rsync -avzP --password-file=/etc/rsyncd/rsyncrhel4easylife.secrets easylife@192.168.145.5::rhel4opt /home/rhel4hoptbak/$(date +'%m-%d-%y')
　　注：你可以把rhel4home.sh和rhel4opt.sh的内容合并到一个文件中，比如都写到rhel4bak.sh中；
　　接着我们修改 /etc/rsyncd/rsyncrhel4root.secrets和rsyncrhel4easylife.secrets的内容；
　　# echo "mike" > /etc/rsyncd/rsyncrhel4root.secrets
　　# echo "keer"> /etc/rsyncd/rsyncrhel4easylife.secrets
　　然后我们再/home目录下创建rhel4homebak和rhel4optbak两个目录，意思是服务器端的rhel4home数据同步到备份服务器上的/home/rhel4homebak下，rhel4opt数据同步到 /home/rhel4optbak/目录下。并按年月日归档创建目录；每天备份都存档；
　　#mkdir /home/rhel4homebak
　　#mkdir /home/rhel4optbak
　　step2：修改crond服务器的配置文件 加入到计划任务
　　#crontab -e
　　加入下面的内容：
　　# Run daily cron jobs at 4:10 every day backup rhel4 data: 
　　10 4 * * * /usr/bin/run-parts /etc/cron.daily.rsync 1> /dev/null
　　注：第一行是注释，是说明内容，这样能自己记住。
　　　　第二行表示在每天早上4点10分的时候，运行 /etc/cron.daily.rsync 下的可执行脚本任务；

　　配置好后，要重启crond 服务器；
　　# killall crond 注：杀死crond 服务器的进程；
　　# ps aux |grep crond 注：查看一下是否被杀死；
　　# /usr/sbin/crond 注：启动 crond 服务器；
　　# ps aux |grep crond 注：查看一下是否启动了？
　　root 3815 0.0 0.0 1860 664 ? S 14:44 0:00 /usr/sbin/crond
　　root 3819 0.0 0.0 2188 808 pts/1 S+ 14:45 0:00 grep crond
六、FAQ
　　Q：如何通过ssh进行rsync，而且无须输入密码？
　　A：可以通过以下几个步骤
　　1. 通过ssh-keygen在server A上建立SSH keys，不要指定密码，你会在~/.ssh下看到identity和identity.pub文件
　　2. 在server B上的home目录建立子目录.ssh
　　3. 将A的identity.pub拷贝到server B上
　　4. 将identity.pub加到~[user b]/.ssh/authorized_keys
　　5. 于是server A上的A用户，可通过下面命令以用户B ssh到server B上了。e.g. ssh -l userB serverB。这样就使server A上的用户A就可以ssh以用户B的身份无需密码登陆到server B上了。
　　Q：如何通过在不危害安全的情况下通过防火墙使用rsync?

　　A：解答如下：
　　这通常有两种情况，一种是服务器在防火墙内，一种是服务器在防火墙外。无论哪种情况，通常还是使用ssh，这时最好新建一个备份用户，并且配置sshd仅允许这个用户通过RSA认证方式进入。如果服务器在防火墙内，则最好限定客户端的IP地址，拒绝其它所有连接。如果客户机在防火墙内，则可以简单允许防火墙打开TCP端口22的ssh外发连接就ok了。
　　Q：我能将更改过或者删除的文件也备份上来吗？
　　A：当然可以。你可以使用如：rsync -other -options -backupdir = ./backup-2000-2-13 ...这样的命令来实现。这样如果源文件:/path/to/some/file.c改变了，那么旧的文件就会被移到./backup-2000-2-13/path/to/some/file.c，这里这个目录需要自己手工建立起来
　　Q：我需要在防火墙上开放哪些端口以适应rsync？

　　A：视情况而定。rsync可以直接通过873端口的tcp连接传文件，也可以通过22端口的ssh来进行文件传递，但你也可以通过下列命令改变它的端口：

　　rsync --port 8730 otherhost::
　　或者
　　rsync -e 'ssh -p 2002' otherhost:
　　Q：我如何通过rsync只复制目录结构，忽略掉文件呢？

　　A：rsync -av --include '*/' --exclude '*' source-dir dest-dir
　　Q：为什么我总会出现"Read-only file system"的错误呢？
　　A：看看是否忘了设"read only = no"了
　　Q：为什么我会出现'@ERROR: invalid gid'的错误呢？
　　A：rsync使用时默认是用uid=nobody;gid=nobody来运行的，如果你的系统不存在nobody组的话，就会出现这样的错误，可以试试gid = ogroup或者其它
　　Q：绑定端口873失败是怎么回事？
　　A：如果你不是以root权限运行这一守护进程的话，因为1024端口以下是特权端口，会出现这样的错误。你可以用--port参数来改变。
　　Q：为什么我认证失败？
　　A：从你的命令行看来：你用的是
　　> bash$ rsync -a 144.16.251.213::test test
　　> Password:
　　> @ERROR: auth failed on module test
　　>
　　> I dont understand this. Can somebody explain as to how to acomplish this.
　　> All suggestions are welcome.
　　应该是没有以你的用户名登陆导致的问题，试试rsync -a max@144.16.251.213::test test
　　Q: 出现以下这个讯息, 是怎么一回事?
　　@ERROR: auth failed on module xxxxx
　　rsync: connection unexpectedly closed (90 bytes read so far)
　　rsync error: error in rsync protocol data stream (code 12) at io.c(150)
　　A: 这是因为密码设错了, 无法登入成功, 请再检查一下 rsyncd.secrets 中的密码设定, 二端是否一致?
　　Q: 出现以下这个讯息, 是怎么一回事?
　　password file must not be other-accessible
　　continuing without password file
　　Password:
　　A: 这表示 rsyncd.secrets 的档案权限属性不对, 应设为 600。请下 chmod 600 rsyncd.secrets
　　Q: 出现以下这个讯息, 是怎么一回事?
　　@ERROR: chroot failed
　　rsync: connection unexpectedly closed (75 bytes read so far)
　　rsync error: error in rsync protocol data stream (code 12) at io.c(150)
　　A: 这通常是您的 rsyncd.conf 中的 path 路径所设的那个目录并不存在所致.请先用 mkdir开设好备份目录.
完！
```

# rsync命令排除文件和文件夹(exclude-from)

```shell
假设最开始的命令是这样的 
rsync -e 'ssh -p 30000' -avl --delete --stats --progress demo@123.45.67.890:/home/demo /backup/ 

一、排除单独的文件夹和文件 

要排除sources文件夹，我们可以添加 '--exclude' 选项： 

--exclude 'sources' 

命令是这样的： 
rsync -e 'ssh -p 30000' -avl --delete --stats --progress --exclude 'sources' demo@123.45.67.890:/home/demo /backup/ 

要排除 "public_html" 文件夹下的 "database.txt" 文件： 

--exclude 'public_html/database.txt' 

命令是这样的： 
rsync -e 'ssh -p 30000' -avl --delete --stats --progress --exclude 'sources' --exclude 'public_html/database.txt' demo@123.45.67.890:/home/demo /backup/ 

二、使用 '--exclude-from' 排除多个文件夹和文件 

建立文件： 
/home/backup/exclude.txt 

在里面定义要排除的文件夹和文件 
sources 
public_html/database.* 
downloads/test/* 

经过测试一般 
文件夹 
uploads 
download/softs/ 

使用指令： 
--exclude-from '/home/backup/exclude.txt' 

最后的命令如下： 
rsync -e 'ssh -p 30000' -avl --delete --stats --progress --exclude-from '/home/backup/exclude.txt' demo@123.45.67.890:/home/demo /backup/


问题：如何避开同步指定的文件夹？ --exclude 

rsync --exclude files and folders 
http://articles.slicehost.com/2007/10/10/rsync-exclude-files-and-folders 
很常见的情况：我想同步/下的 /usr /boot/ ， 但是不想复制/proc /tmp 这些文件夹 
如果想避开某个路径 直接添加--exclude 即可 
比如--exclude “proc” 
--exclude ‘sources' 
Note: the directory path is relative to the folder you are backing up. 
注意：这个路径必须是一个相对路径，不能是绝对路径 

例子：源服务器/home/yjwan/bashshell有一个checkout文件夹 
[root@CentOS5-4 bashshell]# ls -dl checkout 
drwxr-xr-x 2 root root 4096 Aug 21 09:14 checkou 
现在想要完全避开复制这个文件夹内容怎么办？ 
目标服务器执行 
rsync -av --exclude “checkout” yjwan@172.16.251.241:/home/yjwan/bashshell /tmp 
将不会复制这个文件夹 
[root@free /tmp/bashshell]# ls -d /tmp/bashshell/checkout 
ls: /tmp/bashshell/checkout: No such file or directory 

注意: 

1事实上，系统会把文件和文件夹一视同仁，如果checkout是一个文件，一样不会复制 

2 如果想避开复制checkout里面的内容，可以这么写--exclude “checkout/123” 

3 切记不可写为 --exclude “/checkout”这样绝对路径 
这样写 将不会避免checkout被复制 
比如 
[root@free /tmp/bashshell]# rsync -av --exclude “/checkout” yjwan@172.16.251.241:/home/yjwan/bashshell /tmp 
receiving file list … done 
bashshell/checkout/ 

4可以使用通配符 避开不想复制的内容 
比如--exclude “fire*” 
那么fire打头的文件或者文件夹全部不会被复制 
5如果想要避开复制的文件过多，可以这么写 
--exclude-from=/exclude.list 

exclude.list 是一个文件，放置的位置是绝对路径的/exclude.list ，为了避免出问题，最好设置为绝对路径。 

里面的内容一定要写为相对路径 

比如 我想避开checkout文件夹和fire打头的文件 

那么/exclude.list 写为 
checkout 
fire* 
然后执行以下命令，注意写为--exclude-from或者--exclude-from=都可以 
但是不能为--exclude 
rsync -av --exclude-from=”/exclude.list” yjwan@172.16.251.241:/home/yjwan/bashshell /tmp 
检查结果：确实避开了checkout文件夹和fire打头的文件 

问题：如何计算对比复制以后的文件数量是否正确呢？ 

1 查看错误日志，看是否复制时候出问题了 
2在源服务器执行可知道具体文件和文件夹的总个数 
ls –AlR|grep “^[-d]”|wc 
然后目标服务器在计算一遍个数 
看看数字是不是能对的上就ok了 
对不上再研究怎么回事 
3现在的问题是：如果我使用了--exclude参数就麻烦了 

我怎么知道要复制几个文件？ 

首先，前面命令时候提到过一种写法，就是只有源地址，没有目标地址的写法，这种写法可以用来列出所有应该被复制的文件 

那么用这个命令，可以计算出这个/root/bashshell下面文件和文件夹数量 

在服务器端执行 

[root@CentOS5-4 bashshell]# rsync -av /root/bashshell/ |grep “^[-d]” | wc 
62 310 4249 
和ls 得到的结果一致的 
[root@CentOS5-4 bashshell]# ls -AlR |grep “^[-d]“|wc 
62 558 3731 
因此，比如说我不要fire 打头的文件，可以在服务器端先这样计算要复制的文件 
[root@CentOS5-4 bashshell]# rsync -av --exclude “fire*” /root/bashshell/ |grep “^[-d]” | wc 
44 220 2695 
然后复制过去 
看目标机器的文件和文件夹数量为 
[root@free /tmp]# ls -AlR /tmp/bashshell/ |grep “^[-d]“|wc 
44 396 2554 
可以知道2者是同步的 

问题：Rsync的其他几个常见参数 
1 
-z –compress compress file data during the transfer 
--compress-level=NUM explicitly set compression level 
--skip-compress=LIST skip compressing files with suffix in LIST 
压缩传输，如果网络带宽不够，那么应该压缩以后传输，消耗的当然是机器资源，但是如果内网传输的话，文件数量不是很多的话，这个参数不必要的。 
2 
--password-file=FILE 
前面说过了，只有远端机器是rsync服务器，才能用这个参数 
如果你以为个FILE写的是ssh 登陆的密码，那就大错特错了，不少人犯了这个错误。 
3 
–stats: Adds a little more output regarding the file transfer status. 
4 
–progress: shows the progress of each file transfer. Can be useful to know if you have large files being backup up. 

关于这个参数： 

I frequently find myself adding the -P option for large transfers. It preserves partial transfers in case of interuption, and gives a progress report on each file as it's being uploaded. 
I move large media files back and forth on my servers, so knowing how long the transfer has remaining is very useful. 
•Previous Entry: nginx 每天定时切割Nginx日志的脚本 
•Next Entry: 如何开启MySQL的远程帐号
```

