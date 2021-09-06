# Linux系统非默认路径部署mysql

```shell
1，解压mysql包
[root@localhost ~]# tar -xzvf mysql-5.6.44-linux-glibc2.12-x86_64.tar.gz
2，增加mysql组与用户
[root@localhost ~]# groupadd mysql
[root@localhost ~]# useradd -r -g mysql mysql
3，重命名mysql安装目录
[root@localhost ~]# mv mysql-5.6.44-linux-glibc2.12-x86_64 mysql
4，安装mysql所需依赖包
[root@localhost ~]# yum install libaio* -y
[root@localhost ~]# yum install numa* -y
5改变安装路径属组位mysql
[root@localhost ~]# chown -R mysql:mysql mysql
6，在安装路径script下执行安装脚本
5.6
[root@localhost ~]# cd scripts/
[root@localhost ~]# ./mysql_install_db --user=mysql

5.7
./mysqld  --defaults-file=/data/my.cnf --initialize --user=mysql --datadir=/data/mysqldata --basedir=/data/soft/mysql/bin
7，安装完成后更改安装目录及data的属组
[root@localhost ~]# chown -R root:root mysql
[root@localhost ~]# chown -R mysql:mysql data
8，将该文件内的目录修改为实际安装目录
[root@localhost ~]# vi support-files/mysql.server 

mysqld_pid_file_path=
if test -z "$basedir"
then
  basedir=/usr/local/mysql
  bindir=/usr/local/mysql/bin
  if test -z "$datadir"
  then
    datadir=/usr/local/mysql/data
  fi
  sbindir=/usr/local/mysql/bin
  libexecdir=/usr/local/mysql/bin

9，将修改后的文件复制到init.d目录下作为启动文件并启动mysql服务
[root@localhost ~]# cp support-files/mysql.server  /etc/init.d/mysql
[root@localhost ~]# service mysql start
[root@localhost ~]# ps –ef|grep mysql
10，将密码文件软连接至tmp目录下
[root@localhost ~]# ln -s /var/lib/mysql/mysql.sock /tmp/mysql.sock
11，修改mysql 的root密码
[root@localhost ~]# ./mysql/bin/mysqladmin -u root password '密码'

12，将mysql命令软连接至默认路径
[root@localhost ~]# ln -s /data01/mysqlsoft/mysql/bin/mysql /usr/local/bin/mysql
```

# 多实例安装 5.7

## 多实例介绍

一台服务器上安装多个MySQL数据库实例
可以充分利用服务器的硬件资源
通过mysqld_multi进行管理

## 安装要求

```shell
MySQL实例1 - mysql1
port = 3306
datadir = /data1
socket = /tmp/mysql.sock1

MySQL实例2 - mysql2
port = 3307
datadir = /data2
socket = /tmp/mysql.sock2

MySQL实例3 - mysql3
port = 3308
datadir = /data3
socket = /tmp/mysql.sock3

MySQL实例4 - mysql4
port = 3309
datadir = /data4
socket = /tmp/mysql.sock4
该三个参数必须定制，且必须不同 (port / datadir / socket) 
server-id和多数据库实例没有关系，和数据库复制有关系。
```

## 安装操作

```shell
多实例配置文件，可以mysqld_multi --example 查看例子

#
[root@MyServer /]> cat /etc/my.cnf 
#[client]           # 这个标签如果配置了用户和密码，

并且[mysqld_multi]下没有配置用户名密码，
则mysqld_multi stop时, 会使用这个密码
如果没有精确的匹配，则匹配[client]标签

#user = root        
#password = 123
#-------------
[mysqld_multi]
mysqld = /usr/local/mysql/bin/mysqld_safe
mysqladmin = /usr/local/mysql/bin/mysqladmin
user = multi_admin
pass = 123  # 官方文档中写的password，但是存在bug，需要改成pass(v5.7.9)

            # 写成password，start时正常，stop时，报如下错误

            # Access denied for user 'multi_admin'@'localhost' (using password: YES)

log = /var/log/mysqld_multi.log


[mysqld1]  # mysqld后面的数字为GNR, 是该实例的标识
           # mysqld_multi  start 1,  mysqld_multi start 2-4
server-id = 11
socket = /tmp/mysql.sock1
port = 3306
bind_address = 0.0.0.0
datadir = /data1
user = mysql
performance_schema = off
innodb_buffer_pool_size = 32M
skip_name_resolve = 1
log_error = error.log
pid-file = /data1/mysql.pid1

[mysqld2]
server-id = 12
socket = /tmp/mysql.sock2
port = 3307
bind_address = 0.0.0.0
datadir = /data2
user = mysql
performance_schema = off
innodb_buffer_pool_size = 32M
skip_name_resolve = 1
log_error = error.log
pid-file = /data2/mysql.pid2

[mysqld3]
server-id = 13
socket = /tmp/mysql.sock3
port = 3308
bind_address = 0.0.0.0
datadir = /data3
user = mysql
performance_schema = off
innodb_buffer_pool_size = 32M
skip_name_resolve = 1
log_error = error.log
pid-file = /data3/mysql.pid3

[mysqld4]
server-id = 14
socket = /tmp/mysql.sock4
port = 3309
bind_address = 0.0.0.0
datadir = /data4
user = mysql
performance_schema = off
innodb_buffer_pool_size = 32M
skip_name_resolve = 1
log_error = error.log
pid-file = /data4/mysql.pid4
#
# 准备好数据目录，并初始化安装
#
[root@MyServer ~]> mkdir /data1
[root@MyServer ~]> mkdir /data2
[root@MyServer ~]> mkdir /data3
[root@MyServer ~]> mkdir /data4
[root@MyServer ~]> chown mysql.mysql /data{1..4}
[root@MyServer ~]> mysqld --initialize --user=mysql --datadir=/data1
#
# 一些日志输出，并提示临时密码，下同
#
[root@MyServer ~]> mysqld --initialize --user=mysql --datadir=/data2
[root@MyServer ~]> mysqld --initialize --user=mysql --datadir=/data3
[root@MyServer ~]> mysqld --initialize --user=mysql --datadir=/data4

# 安装后，需要检查error.log 确保没有错误出现

[root@MyServer ~]> cp /usr/local/mysql/support-files/mysqld_multi.server  /etc/init.d/mysqld_multid 

# 拷贝启动脚本，方便自启

[root@MyServer ~]> chkconfig mysqld_multid on
[root@MyServer ~]> mysqld_multi  start
[root@MyServer ~]> mysqld_multi  report
Reporting MySQL servers
MySQL server from group: mysqld1 is running
MySQL server from group: mysqld2 is running
MySQL server from group: mysqld3 is running
MySQL server from group: mysqld4 is running
[root@MyServer ~]> netstat -tunlp | grep mysql
[root@MyServer ~]> netstat -tunlp | grep mysql
tcp        0      0 :::3307                     :::*                        LISTEN      6221/mysqld         
tcp        0      0 :::3308                     :::*                        LISTEN      6232/mysqld         
tcp        0      0 :::3309                     :::*                        LISTEN      6238/mysqld         
tcp        0      0 :::3306                     :::*                        LISTEN      6201/mysqld         

[root@MyServer ~]> mysql -u root -S /tmp/mysql.sock1 -p -P3306
#
# 使用-S /tmp/mysql.sock1 进行登录，并输入临时密码后，修改密码，下同
#
[root@MyServer ~]> mysql -u root -S /tmp/mysql.sock2 -p -P3307
[root@MyServer ~]> mysql -u root -S /tmp/mysql.sock3 -p -P3308

[root@MyServer ~]> mysql -u root -S /tmp/mysql.sock4 -p -P3309
--
-- mysql1
--

mysql> show variables like "port";
 +---------------+-------+
| Variable_name | Value |
+---------------+-------+
| port          | 3306  |
+---------------+-------+
1 row in set (0.00 sec)

mysql> show variables like "socket";
+---------------+------------------+
| Variable_name | Value            |
+---------------+------------------+
| socket        | /tmp/mysql.sock1 |
+---------------+------------------+
1 row in set (0.01 sec)

mysql> show variables like "datadir";
+---------------+---------+
| Variable_name | Value   |
+---------------+---------+
| datadir       | /data1/ |
+---------------+---------+
1 row in set (0.00 sec)

--
-- 这样才能进行关闭数据库的操作
-- 和[mysqld_multi]中的user，pass(注意在5.7.9中不是password)对应起来 （类比[client]标签）

-- 一会测试federated链接，需要增加federated参数，并重启mysql2
--

mysql> create user 'multi_admin'@'localhost' identified by '123';
Query OK, 0 rows affected (0.00 sec)
mysql> grant shutdown on *.* to 'multi_admin'@'localhost';

--
-- mysql2, mysql3, mysql4 类似。可以看到与my.cnf中对应的port和socket
```



# 多实例5.6

在一台物理服务器上安装一套Mysql软件程序，创建多个Mysql实例，每个Mysql实例拥有各自独立的数据库、配置文件和启动脚本，多个Mysql实例共享服务器硬件资源（CPU，MEM，磁盘，网络）。可以将多实例形像的理解成一个房子里的多个房间，在房子里的浴室、厨房和客厅是公用资源。

多实例优劣
优点：
    1、  充分利用服务器富余硬件资源，节约了硬件成本；
    2、  在业务量并不太大，并发度也不高的场景是不错的选择；
缺点：
    1、  共享硬件资源，容易造成资源争用；
    2、  并不适用于大规模高并发的应用场景；

多实例配置思路

## 一、安装Mysql软件 （省略，假定软件的安装目录/usr/local/mysql）

## 二、创建库目录并授权

    mkdir –p /data/{3306,3307}/data   （存放数据文件，二进制日志，sock和pid文件）
    mkdir –p /data/{3306,3307}/logs  （存放错误日志和慢查询日志）
    chown –R mysql.mysql /data

## 三、修改配置文件

```shell
1、修改3306的配置文件
    vi /data/3306/my.cnf
    
[client] 
port = 3306
socket = /data/3306/data/mysql.sock

[mysqld]
port=3306
socket = /data/3306/data/mysql.sock
pid-file = /data/3306/data/mysql.pid
basedir = /usr/local/mysql
datadir = /data/3306/data
server-id=1
log-bin=mysql-bin
log-bin-index= mysql-bin.index


log_error=/data/3306/logs/mysql-error.log   
slow_query_log_file=/data/3306/logs/mysql-slow.log
slow_query_log=1

2、修改3307的配置文件
    vi /data/3307/my.cnf

[client]
port = 3307
socket = /data/3307/data/mysql.sock

[mysqld]
port=3307
socket = /data/3307/data/mysql.sock
pid-file = /data/3307/data/mysql.pid
basedir = /usr/local/mysql
datadir = /data/3307/data
server-id=3
log-bin=mysql-bin
log-bin-index= mysql-bin.index


log_error=/data/3307/logs/mysql-error.log   
slow_query_log_file=/data/3307/logs/mysql-slow.log
slow_query_log=1

其余配置文件参数可根据实际情况做修改
```


## 四、初始化数据库 

```shell
cd /usr/local/mysql/scripts

1、3306数据库初始化
      ./mysql_install_db --defaults-file=/data/3306/my.cnf--user=mysql  --basedir=/usr/local/mysql --datadir=/data/3306/data

2、3307数据库初始化
      ./mysql_install_db --defaults-file=/data/3307/my.cnf--user=mysql --basedir=/usr/local/mysql --datadir=/data/3307/data

3.MySQL多实例启动
# /usr/local/mysql/bin/mysqld_safe --defaults-file=/data/3306/my.cnf 2>&1 > /dev/null &
# /usr/local/mysql/bin/mysqld_safe --defaults-file=/data/3307/my.cnf 2>&1 > /dev/null &

4.MySQL多实例设置密码
# /usr/local/mysql/bin/mysqladmin -uroot password 123456 -S /data/3306/mysql.sock
# /usr/local/mysql/bin/mysqladmin -uroot password 123456 -S /data/3307/mysql.sock

5.测试MySQL多实例设置密码
# mysql -uroot -p123456 -S /data/3306/mysql.sock
# mysql -uroot -p123456 -S /data/3307/mysql.sock

6.查看MySQL多实例监听端口
# netstat -lntup|grep 330
tcp 0 0 :::3306 :::* LISTEN 3848/mysqld 
tcp 0 0 :::3307 :::* LISTEN 4885/mysqld
```

## 五、修改启动脚本

```shell
可自行编写一个启动脚本，可参考/etc/init.d/portmap进行编写
    脚本思想：
    1、  启动mysql，使用mysqld_safe启动
   mysqld_safe --defaults-file=/data01/mysqlsoft/mysql/my.cnf --user=mysql --basedir=/data01/mysqlsoft/mysql --datadir=/data01/mysqlsoft/mysql/data  &

    2、  停止mysql，使用mysqladmin平滑停止

   mysqladmin –uroot –p –S /data01/mysqlsofy/mysql/data/mysql.sock shutdown
    3、  重启mysql
    先停止，后启动。
    示例：


#!/bin/sh

# This is an interactive program, we needthe current locale

[ -f /etc/profile.d/lang.sh ] && ./etc/profile.d/lang.sh

# We can't Japanese on normal console atboot time, so force.

if [ "$LANG" = "ja" -o"$LANG" = "ja_JP.eucJP" ]; then
   if [ "$TERM" = "linux" ] ; then
   LANG=C
   fi
fi

# Source function library.

. /etc/init.d/functions

cmdPath="/usr/local/mysql/bin"
myPath="/data/3307"
softPath="/usr/local/mysql"
socketfile="$myPath/data/mysql.sock"
my_user="root"
my_pass="123456"

start(){
if [ ! -e "$socketfile" ];then
printf "Mysqldstarting......\n"
$cmdPath/mysqld_safe--defaults-file=$myPath/my.cnf --user=mysql \
--basedir=$softPath--datadir=$myPath/data &>/dev/null &
sleep 2
   else
printf "Mysqld alreadyrunning\n" && exit 1
   fi
}


stop(){
   if [ -e "$socketfile" ];then
printf "Mysqldstoping......\n"
$cmdPath/mysqladmin-u"$my_user" -p"$my_pass" \
-S "$socketfile" shutdown &>/dev/null
[ $  -ne 0 ] && echo"error username or password!!!" && exit 1
sleep 3
   else
printf "Mysqld alreadyclosed\n" && exit 1
   fi
}


restart(){
   stop
start
}

case "$1" in
   start)
start
   ;;
   stop)
stop
   ;;
   restart)
restart
   ;;
   status)
status mysqld
   ;;
   *)
echo "Usage: $0{start|stop|restart|status}"
exit 1
esac
```
## 六、测试


```shell
   1、  查看进程
ps –ef|grep mysqld |grep –v grep
  可以看到四个进程
 
   2、  查看端口
     netstat –nltup|grep 330
   可以看到3306与3307两个监听端口
 
   3、  测试mysql脚本
   /data/3306/data/mysql start
  /data/3306/data/mysql stop
  /data/3306/data/mysql restart
  /data/3306/data/mysql xxxx
```

## 七、多实例本地及远程登陆

  1、本地登陆，一定要添加sock区别不同实例


      mysql –uroot –p123456 –S /data/3306/data/mysql.sock
  2、远程登陆，与普通mysql连接一样，需要授权


      mysql –uroot –p123456 –h 192.168.31.200 –P 3307

## 八、多实例修改口令


      1、非交互式修改口令
     mysqladmin –uroot –p123456 password=’newpass’ –S/data/3306/data/mysql.sock
     
       2、root帐户连接到mysql，执行：
        mysql>set passwordfor root@’192.168.31.%’=password(‘newpass’)；
     
       3、直接修改mysql.user表来实现：
          mysql>update userset password=password('newpass') where host="192.168.31.%"                      and user="root"；
       mysql>flush privileges；



# 在centos7上部署mysql8.0.13 

## 一，安装依赖包

```shell
yum install bison gcc gcc-c++ ncurses-devel openssl-devel
```

## 二、解压源码包，并创建相关目录和用户

```shell
tar -xvf mysql-8.0.13-linux-glibc2.12-x86_64.tar.xz
mv /data/soft/mysql-8.0.13-linux-glibc2.12-x86_64 mysql
mv mysql /usr/local/
cd /usr/local/
groupadd mysql
useradd -r -g mysql mysql
mkdir /data/mysql
chown -R mysql:mysql /data/mysql/
```

## 三、数据库初始化

```shell
cd /usr/local/mysql/bin
mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql
```

## 四、创建并配置配置文件

```shell
cd /usr/local/mysql/support-files/
touch my-default.cnf
chmod 777 ./my-default.cnf
vi   my-default.cnf(编辑配置文件内容，内容如下)
cp support-files/my-default.cnf /etc/my.cnf 

配置文件内容：
[mysqld]
basedir = /usr/local/mysql
datadir = /data/mysql
socket = /tmp/mysql.sock
log-error = /data/mysql/error.log
pid-file = /data/mysql/mysql.pid
tmpdir = /tmp
port = 3306
#lower_case_table_names = 1
server_id = .....
socket = .....
#lower_case_table_names = 1
max_allowed_packet=32M
default-authentication-plugin = mysql_native_password
#lower_case_file_system = on
#lower_case_table_names = 1
log_bin_trust_function_creators = ON
Remove leading # to set options mainly useful for reporting servers.
The server defaults are faster for transactions and fast SELECTs.
Adjust sizes as needed, experiment to find the optimal values.
join_buffer_size = 128M
sort_buffer_size = 2M
read_rnd_buffer_size = 2M
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
```

## 五，配置MySQL服务与开机自启动

```shell
cd /usr/local/mysql/support-files/
cp mysql.server /etc/init.d/mysql 
chmod +x /etc/init.d/mysql
chkconfig --add mysql
vim /etc/ld.so.conf --> 添加“/usr/local/mysql/lib”
```

## 六、配置环境变量

```shell
vi .bash_profile --> export PATH=$PATH:/usr/local/mysql/bin:/usr/local/mysql/lib
. .bash_profile
```

## 七、启动服务

```shell
service mysql start
```

## 八、修改密码

```shell
alter user 'root'@'localhost' identified by '123456';
```



# 主备（5.7）

## 一、安装mysql mysqlnode1、mysqlnode2

```shell
1,创建目录
mkdir /data
cd /data/
mkdir mysql
mkdir redolog
mkdir undolog

2，创建用户
groupadd mysql
useradd -r -g mysql mysql

3、创建配置文件
cd /data/mysql/
vi my.cnf

4，更改目录属组
chown -R mysql:mysql mysql/

5、移动并重命名mysql软件目录
mv mysql-5.7.27-linux-glibc2.12-x86_64 /usr/local/mysql
6，初始化数据库
cd /usr/local/mysql/bin
./mysqld --defaults-file=/data/mysql/my.cnf --initialize --user=mysql  --basedir=/usr/local/mysql --datadir=/data/mysql/data

7，启动数据库
mysqld_safe --defaults-file=/data/mysql/my.cnf 2>&1 > /dev/null &

8,修改密码
ALTER USER USER() IDENTIFIED BY 'mysqltest';
```

## 二、主备实战（部署）

确定主从serverid不一致
确定主binlog打开

### 1,主库授权账号

```shell
grant replication slave on *.* to 'rep'@'192.168.202.10' identified by '123456';
```

### 2,刷新至磁盘

```shell
flush privileges;
```

### 3,备份主库

```shell
1）先锁表
flush table with read lock;

2)确定锁表之后binlog的点
mysql> show master status;
+------------+----------+--------------+------------------+------------------------------------------+
| File       | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+------------+----------+--------------+------------------+------------------------------------------+
| bin.000005 |      574 |              |                  | d6d654db-73d9-11e9-964c-000c297deb25:1-3 |
+------------+----------+--------------+------------------+------------------------------------------+

mysql> show master logs;
+------------+-----------+
| Log_name   | File_size |
+------------+-----------+
| bin.000001 |     65444 |
| bin.000002 |   1193884 |
| bin.000003 |       364 |
| bin.000004 |       214 |
| bin.000005 |       574 |
+------------+-----------+

3）开始备份
mysqldump -uroot -p123456 -S /data02/3306/data/mysql.sock -A -B --events --master-data=2 >/opt/rep.sql
vi rep.sql
搜索rep.sql中changemaster位置是否与以上一致

4）解锁表
unlock tables
```

### 4,将数据灌到从库

```shell
1）mysql -uroot -p123456  -S /data02/3307/data/mysql.sock < /opt/rep.sql

2）在从库执行
CHANGE MASTER TO
MASTER_HOST='192.168.202.10',
MASTER_PORT=3306,
MASTER_USER='rep',
MASTER_PASSWORD='123456',
MASTER_LOG_FILE='bin.000019',
MASTER_LOG_POS=2630;

3) 从库执行：查看master.info是否生成信息
select * from slave_master_info\G;

4）从库执行：mysql> start slave;

5）从库执行：查看是否启动
mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.91.128
                  Master_User: rep
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: bin.000005
          Read_Master_Log_Pos: 574
               Relay_Log_File: relay.000002
                Relay_Log_Pos: 308
        Relay_Master_Log_File: bin.000005
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 574
              Relay_Log_Space: 502
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 11
                  Master_UUID: d6d654db-73d9-11e9-964c-000c297deb25
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: f3071fbe-73d9-11e9-964e-000c297deb25:1
                Auto_Position: 0
1 row in set (0.00 sec)
```


备注：若备份时--master-data=1则
MASTER_LOG_FILE='bin.000005',MASTER_LOG_POS=574;不需要添加。导入备库的binlog点会自动找到
若备份时加-x则可以省略锁表解锁步骤

查看线程状态
show processlist;



# 主从同步半同步模式

## 安装使用

下面来看看如何安装使用半同步,大部分mysql本身并没有预装半同步的组件,需要另外安装,但是一般mysql的包里面会自带so文件,所以只要手动加载一下就可以用了.

### 1先检查下有没有装

```shell
#查找是否有semisync字母,有就是装了,没有就是没装,默认是不安装的,所以请看下一步
mysql> show plugins;
```

### 2然后我们开始准备安装的事情:

```shell
#查找mysql插件目录位置
mysql> show variables like 'plugin_dir';
+---------------+------------------------------------+
| Variable_name | Value                              |
+---------------+------------------------------------+
| plugin_dir    | /usr/local/mysql/lib/mysql/plugin/ |
+---------------+------------------------------------+
1 row in set (0.00 sec)
去看一下相关文件夹:

#查看目录文件是否存在
[root@pingtest1 ~]# ll /usr/local/mysql/lib/mysql/plugin/
总用量 25328
-rwxr-xr-x 1 root root    16916 3月   4 01:18 adt_null.so
-rwxr-xr-x 1 root root   183009 3月   4 01:18 audit_log.so
-rwxr-xr-x 1 root root    44095 3月   4 01:18 auth_pam_compat.so
-rwxr-xr-x 1 root root    45929 3月   4 01:18 auth_pam.so
-rwxr-xr-x 1 root root    27406 3月   4 01:18 auth.so
-rwxr-xr-x 1 root root    13607 3月   4 01:18 auth_socket.so
-rwxr-xr-x 1 root root    26229 3月   4 01:18 auth_test_plugin.so
-rw-r--r-- 1 root root      227 3月   3 21:27 daemon_example.ini
drwxr-xr-x 2 root root     4096 3月   4 01:23 debug
-rwxr-xr-x 1 root root  4702357 3月   4 01:20 dialog.so
-rwxr-xr-x 1 root root  2212305 3月   4 01:18 handlersocket.so
-rwxr-xr-x 1 root root 14950125 3月   4 01:22 ha_tokudb.so
-rwxr-xr-x 1 root root   834597 3月   4 01:18 innodb_engine.so
-rwxr-xr-x 1 root root    39169 3月   4 01:18 libdaemon_example.so
-rwxr-xr-x 1 root root    27048 3月   4 01:18 libfnv1a_udf.so
-rwxr-xr-x 1 root root    27089 3月   4 01:18 libfnv_udf.so
-rwxr-xr-x 1 root root   779519 3月   4 01:18 libmemcached.so
-rwxr-xr-x 1 root root    28683 3月   4 01:18 libmurmur_udf.so
-rwxr-xr-x 1 root root    17898 3月   4 01:18 mypluglib.so
-rwxr-xr-x 1 root root    12224 3月   4 01:18 mysql_no_login.so
-rwxr-xr-x 1 root root    18574 3月   4 01:18 qa_auth_client.so
-rwxr-xr-x 1 root root    27059 3月   4 01:18 qa_auth_interface.so
-rwxr-xr-x 1 root root    13877 3月   4 01:18 qa_auth_server.so
-rwxr-xr-x 1 root root   395960 3月   4 01:18 query_response_time.so
-rwxr-xr-x 1 root root    56417 3月   4 01:18 scalability_metrics.so
-rwxr-xr-x 1 root root   537609 3月   4 01:18 semisync_master.so
-rwxr-xr-x 1 root root   289069 3月   4 01:18 semisync_slave.so
-rwxr-xr-x 1 root root   357058 3月   4 01:18 tokudb_backup.so
-rwxr-xr-x 1 root root   188402 3月   4 01:18 validate_password.so
看到下面两个,就是半同步的组件了,一个是主库组件,一个是从库组件,你可以两个都装上或者只装一个.

semisync_master.so
semisync_slave.so
```

### 3下面开始正式安装:

```shell
#在主库上执行
mysql> install plugin rpl_semi_sync_master soname 'semisync_master.so';
mysql> show plugins;
#看到下面这个就证明成功了
rpl_semi_sync_master | ACTIVE | REPLICATION | semisync_master.so | GPL
从库当然也要做

#然后在从库执行
mysql> install plugin rpl_semi_sync_slave soname 'semisync_slave.so';
mysql> show plugins;
#看到下面这个就证明成功了
rpl_semi_sync_slave  | ACTIVE | REPLICATION | semisync_slave.so  | GPL
安装完了,就开始准备启动了,

主库很简单,只要设置一下半同步启动就可以了.

mysql> set global rpl_semi_sync_master_enabled = on;
当然,你也可以写到配置文件,不过写到配置文件要重启才生效,而且还要重新加载组件,所以这就没意思了.

然后到从库,slave要重启动IO线程来生效，否则还是异步的方式复制数据。

mysql> set global rpl_semi_sync_slave_enabled = on;
mysql> stop slave IO_THREAD;
mysql> start slave IO_THREAD;
同样你也能写到配置文件,我就不多说了,反正这就启动完毕了.
```

### 4下面来验证一下是否成功,以下是主库的信息,因为从库很多信息是没有的.

```shell
mysql> show status like '%Rpl_semi_sync%';
+--------------------------------------------+---------+
| Variable_name                              | Value   |
+--------------------------------------------+---------+
| Rpl_semi_sync_master_clients               | 1       |
| Rpl_semi_sync_master_net_avg_wait_time     | 746     |
| Rpl_semi_sync_master_net_wait_time         | 3788497 |
| Rpl_semi_sync_master_net_waits             | 5077    |
| Rpl_semi_sync_master_no_times              | 0       |
| Rpl_semi_sync_master_no_tx                 | 0       |
| Rpl_semi_sync_master_status                | ON      |
| Rpl_semi_sync_master_timefunc_failures     | 0       |
| Rpl_semi_sync_master_tx_avg_wait_time      | 614     |
| Rpl_semi_sync_master_tx_wait_time          | 2797020 |
| Rpl_semi_sync_master_tx_waits              | 4552    |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0       |
| Rpl_semi_sync_master_wait_sessions         | 0       |
| Rpl_semi_sync_master_yes_tx                | 5077    |
| Rpl_semi_sync_slave_status                 | OFF     |
+--------------------------------------------+---------+
15 rows in set (0.00 sec)
解释几个重要的值。

Rpl_semi_sync_master_status:    是否启用了半同步(有时候可能网络超时导致切换成异步)。

Rpl_semi_sync_master_clients:    半同步模式下Slave一共有多少个。

Rpl_semi_sync_master_no_tx:    往slave发送失败的事务数量(最好不要有)。

Rpl_semi_sync_master_yes_tx:    往slave发送成功的事务数量。

看完上面的解析,大概你也知道我这个状态是正常的了.其他延时类别的,大家得看实际情况.
```

### 5来看看我们能设置些什么关于半同步的参数

```shell
mysql> show variables like '%Rpl%';
+------------------------------------+----------+
| Variable_name                      | Value    |
+------------------------------------+----------+
| rpl_semi_sync_master_enabled       | ON       |
| rpl_semi_sync_master_timeout       | 10000    |
| rpl_semi_sync_master_trace_level   | 32       |
| rpl_semi_sync_master_wait_no_slave | ON       |
| rpl_semi_sync_slave_enabled        | OFF      |
| rpl_semi_sync_slave_trace_level    | 32       |
| rpl_stop_slave_timeout             | 31536000 |
+------------------------------------+----------+
7 rows in set (0.00 sec)
也来看看解析:

rpl_semi_sync_master_enabled:    显示是否已开启半同步机制

rpl_semi_sync_master_timeout:    Master等待slave响应的时间，单位是毫秒，默认值是10秒，超过这个时间，slave无响应,将自动转换为异步复制,如果探测到从库恢复后,又从新进入半同步状态

rpl_semi_sync_master_trace_level:    监控等级，一共4个等级（1,16,32,64）。

* 1：general 等级，如：记录时间函数失效 
* 16：detail 等级，记录更加详细的信息 
* 32：net wait等级，记录包含有关网络等待的更多信息 
* 64：function等级，记录包含有关function进入和退出的更多信息

rpl_semi_sync_master_wait_no_slave:    是否允许master 每个事物提交后都要等待slave的receipt信号。默认为on ，每一个事务都会等待，如果slave当掉后，当slave追赶上master的日志时，可以自动的切换为半同步方式，如果为off,则slave追赶上后，也不会采用半同步的方式复制了，需要手工配置。

毫无疑问,这些参数都能通过配置文件或直接set来更改,只要你觉得这个适合你的需求,例如一般我们会把响应时间设成1秒.
```

### 6最后,我们来看看同样的命令在从库会有些什么信息

```shell
mysql> show status like '%Rpl_semi_sync%';
+--------------------------------------------+-------+
| Variable_name                              | Value |
+--------------------------------------------+-------+
| Rpl_semi_sync_master_clients               | 0     |
| Rpl_semi_sync_master_net_avg_wait_time     | 0     |
| Rpl_semi_sync_master_net_wait_time         | 0     |
| Rpl_semi_sync_master_net_waits             | 0     |
| Rpl_semi_sync_master_no_times              | 0     |
| Rpl_semi_sync_master_no_tx                 | 0     |
| Rpl_semi_sync_master_status                | OFF   |
| Rpl_semi_sync_master_timefunc_failures     | 0     |
| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |
| Rpl_semi_sync_master_tx_wait_time          | 0     |
| Rpl_semi_sync_master_tx_waits              | 0     |
| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |
| Rpl_semi_sync_master_wait_sessions         | 0     |
| Rpl_semi_sync_master_yes_tx                | 0     |
| Rpl_semi_sync_slave_status                 | ON    |
+--------------------------------------------+-------+
15 rows in set (0.00 sec)
也正如我刚才说的,很多信息基本上没有,只有最后一行是不一样的,也只是证明从库半同步正常连接中.

 

再看看这个
mysql> show variables like '%Rpl%';
+------------------------------------+----------+
| Variable_name                      | Value    |
+------------------------------------+----------+
| rpl_semi_sync_master_enabled       | OFF      |
| rpl_semi_sync_master_timeout       | 10000    |
| rpl_semi_sync_master_trace_level   | 32       |
| rpl_semi_sync_master_wait_no_slave | ON       |
| rpl_semi_sync_slave_enabled        | ON       |
| rpl_semi_sync_slave_trace_level    | 32       |
| rpl_stop_slave_timeout             | 31536000 |
+------------------------------------+----------+
7 rows in set (0.00 sec)
主要就最后两行:

rpl_semi_sync_slave_enabled:    是否开启了从库半同步
rpl_semi_sync_slave_trace_level:    监控等级,默认也是32

rpl_stop_slave_timeout:    控制stop slave 的执行时间，在重放一个大的事务的时候,突然执行stop slave ,命令 stop slave会执行很久,这个时候可能产生死锁或阻塞,严重影响性能，可以通过这个参数控制stop slave 的执行时间,一般不需要修改.
```

### 7问题汇总

5.7.3新加了一个半同步参数，至少有N个slave接收到日志，然后返回ack，这个半同步事务才能提交，默认是1。当这个值设置到和从库数量相等的话，则效果会等同于全同步复制。

#例如我有3个从库，我现在要设置两个从库应答才能返回事务提交成功
rpl_semi_sync_master_wait_for_slave_count = 2
5.7新功能，在控制半同步模式下 主库在返回给会话事务成功之前提交事务的方式。旧模式是AFTER_COMMIT，新模式是AFTER_SYNC，默认值：AFTER_SYNC 。master 将每个事务写入binlog ,传递到slave，并且刷新到磁盘。master等待slave 反馈接收到事务并刷新到磁盘。一旦接到slave反馈，master在主库提交事务并且返回结果给会话。 在AFTER_SYNC模式下，所有的客户端在同一时刻查看已经提交的数据。假如发生主库crash，所有在主库上已经提交的事务已经同步到slave并记录到relay log。此时切换到从库，可以保障最小的数据损失。

#显然新模式更好，不过5.7默认就是这个参数，可改可不改
rpl_semi_sync_master_wait_point = AFTER_SYNC
而当半同步复制设置N个slave应答，如果当前Slave小于N,取决于rpl_semi_sync_master_wait_no_slave的设置。

#设成0会立刻变成异步复制。
rpl_semi_sync_master_wait_no_slave = 0
#设成1仍然等待应答，直到超时。
rpl_semi_sync_master_wait_no_slave = 1
超时时间rpl_semi_sync_master_timeout的值，不应该短过应用（例如JDBC）连接池或线程池的超时时间，这样应用可能出现一直等待或者是抛出异常的问题。

#例如某些大数据量的操作，随时都超过5分钟，那么我们就要设大一点
set global rpl_semi_sync_master_timeout = 300000



# 通过授权配置读写分离的方法（端口号有误，自行调整）

![image-20210113172703288](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113172703288.png)

![image-20210113172715882](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113172715882.png)

![image-20210113172722191](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113172722191.png)

可以通过参数控制只同步某个库（binlog-do-db）和不同步某个库（binlog-ignore-db），重启mysql主库生效
主库从库都要设置

![image-20210113172730554](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113172730554.png)

# 配置文件(my.cnf)

```shell
查看配置文件读取顺序（参数覆盖，后面的参数会覆盖前面的参数）
mysql --help -vv|grep my.cnf

[client]
user=david
password=88888888

[mysqld]

########basic settings########

server-id = 11
 port = 3306
user = mysql
bind_address = 192.168.105.10   #根据实际情况修改
autocommit = 0                  #5.6.X安装时，需要注释掉，安装完成后再打开 从5.6版本开始才有的autocommit模式
character_set_server=utf8mb4
#init_connect='set names utf8'    #强制以utf8写入数据库
skip_name_resolve = 1
max_connections = 800
max_connect_errors = 1000
datadir = /data/mysql/data      #根据实际情况修改,建议和程序分离存放 ---- 默认在/usr/local/mysql/data下面，权限一定是mysql:mysql
transaction_isolation = READ-COMMITTED
explicit_defaults_for_timestamp = 1
join_buffer_size = 134217728
tmp_table_size = 67108864
tmpdir = /tmp
max_allowed_packet = 16777216
sql_mode = "STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER"
interactive_timeout = 1800
wait_timeout = 1800
read_buffer_size = 16777216
read_rnd_buffer_size = 33554432
sort_buffer_size = 33554432

########log settings########

log_error = error.log
slow_query_log = 1
slow_query_log_file = slow.log
log_queries_not_using_indexes = 1
log_slow_admin_statements = 1
log_slow_slave_statements = 1
log_throttle_queries_not_using_indexes = 10
expire_logs_days = 90              ####删除90天后的binlog####
long_query_time = 2
min_examined_row_limit = 100

########replication settings########

master_info_repository = TABLE
relay_log_info_repository = TABLE
log_bin = bin.log
sync_binlog = 1
gtid_mode = on
enforce_gtid_consistency = 1
log_slave_updates
binlog_format = row 
relay_log = relay.log
relay_log_recovery = 1
binlog_gtid_simple_recovery = 1
slave_skip_errors = ddl_exist_errors        ####从库同步时跳过ddl错误#####

########innodb settings########

innodb_page_size = 8192
innodb_buffer_pool_size = 1G    #根据实际情况修改 ---- 建议配置操作系统内存的70%
innodb_buffer_pool_instances = 8
innodb_buffer_pool_load_at_startup = 1
innodb_buffer_pool_dump_at_shutdown = 1
innodb_lru_scan_depth = 2000
innodb_lock_wait_timeout = 5
innodb_io_capacity = 4000
innodb_io_capacity_max = 8000
innodb_flush_method = O_DIRECT
innodb_file_format = Barracuda
innodb_file_format_max = Barracuda
innodb_log_group_home_dir = /data/mysql/redolog/  #根据实际情况修改 ---- 根据实际情况修改，权限一定是mysql:mysql（默认可以注释掉）
innodb_undo_directory = /data/mysql/undolog/    #根据实际情况修改 ---- 根据实际情况修改，权限一定是mysql:mysql（默认可以注释掉）
innodb_undo_logs = 128       #---- 建议在安装之前就确定好该值，后续修改比较麻烦
innodb_undo_tablespaces = 3     #---- 建议在安装之前就确定好该值，后续修改比较麻烦
innodb_flush_neighbors = 1
innodb_log_file_size = 2G               #根据实际情况修改
innodb_log_buffer_size = 16777216
innodb_purge_threads = 4
innodb_large_prefix = 1
innodb_thread_concurrency = 64
innodb_print_all_deadlocks = 1
innodb_strict_mode = 1
innodb_sort_buffer_size = 67108864

 ########semi sync replication settings########

plugin_dir=/usr/local/mysql/lib/plugin      #根据实际情况修改
plugin_load = "rpl_semi_sync_master=semisync_master.so;rpl_semi_sync_slave=semisync_slave.so"
#loose_rpl_semi_sync_master_enabled = 1                       ####主库半同步模式是否开启（主库配置）####
#loose_rpl_semi_sync_slave_enabled = 1                          ####从库半同步模式是否开启（从库库配置）####
#loose_rpl_semi_sync_master_timeout = 5000                  ####主库等待从库返回同步成功的时间（秒）超时则主库继续提交事务####

[mysqld-5.7]
innodb_buffer_pool_dump_pct = 40
innodb_page_cleaners = 4
innodb_undo_log_truncate = 1
innodb_max_undo_log_size = 2G
innodb_purge_rseg_truncate_frequency = 128
binlog_gtid_simple_recovery=1
log_timestamps=system
transaction_write_set_extraction=MURMUR32
show_compatibility_56=on
```

# mysql启停脚本

```shell
vim /etc/init.d/mysqld_multi

#!/bin/sh
port=3306
mysql_user="root"
mysql_pwd="123456"
CmdPath="/usr/local/mysql/bin"
mysql_sock="/data/${port}/mysql.sock"
#startup function
function_start_mysql()
{
if [ ! -e "$mysql_sock" ];then
printf "Starting MySQL...\n"
/bin/sh ${CmdPath}/mysqld_safe --defaults-file=/data/${port}/my.cnf 2>&1 > /dev/null &
else
printf "MySQL is running...\n"
exit
fi
}
#stop function
function_stop_mysql()
{
if [ ! -e "$mysql_sock" ];then
printf "MySQL is stopped...\n"
exit
else
printf "Stoping MySQL...\n"
${CmdPath}/mysqladmin -u${mysql_user} -p${mysql_pwd} -S /data/${port}/mysql.sock shutdown
fi
}
#restart function
function_restart_mysql()
{
printf "Restarting MySQL...\n"
function_stop_mysql
sleep 2
function_start_mysql
}
case $1 in
start)
function_start_mysql
;;
stop)
function_stop_mysql
;;
restart)
function_restart_mysql
;;
*)
printf "Usage: /etc/init.d/mysql_multi {start|stop|restart} {3306|3307}\n"
esac
```

