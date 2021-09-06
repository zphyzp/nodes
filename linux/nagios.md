# 基于snmp搭建nagios监控（centos7）

## 1、yum安装httpd

## 2、编译安装mysql5.7（安装时住加强制写入utf8参数）、php7.1

## 3、安装nagios依赖包

```shell
 yum -y install httpd httpd-devel gcc glibc glibc-common gd gd-devel perl-devel perl-CPAN fcgi perl-FCGI perl-FCGI-ProcManager
```


## 4、创建ngaios用户和组（把nginx启动用户www加入到nagios相关组）

```shell
[root@nagios nagios-4.3.1]# useradd nagios -s /sbin/nologin 
       [root@nagios nagios-4.3.1]# id www
       [root@nagios nagios-4.3.1]# groupadd nagcmd
       [root@nagios nagios-4.3.1]# usermod -a -G nagcmd nagios 
       [root@nagios nagios-4.3.1]# usermod -a -G nagcmd www
       [root@nagios nagios-4.3.1]# id -n -G nagios
       [root@nagios nagios-4.3.1]# id -n -G www
```
## 5、配置nagios

 ```shell
   [root@client1 nagios-4.3.1]# ./configure --with-command-group=nagcmd
 ```

## 6、编译和安装

```shell
   [root@nagios nagios-4.3.1]# make all
   [root@nagios nagios-4.3.1]# make install-init
   [root@nagios nagios-4.3.1]# make install-commandmode
   [root@nagios nagios-4.3.1]# make install-config
   [root@nagios nagios-4.3.1]# make install    
   [root@nagios nagios-4.3.1]# cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
   [root@nagios nagios-4.3.1]# chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
   [root@nagios nagios-4.3.1]# /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
```

## 7、生成apache配置文件



          [root@nagios nagios-4.3.1]# make install-webconf
    /
         /usr/bin/install -c -m 644 sample-config/httpd.conf /etc/httpd/conf.d/nagios.conf
    i
           if [ 0 -eq 1 ]; then \
     ln -s /etc/httpd/conf.d/nagios.conf /etc/apache2/sites-enabled/nagios.conf; \
     f
          fi
       *
      *** Nagios/Apache conf file installed ***
## 8、生成nagios web界面的验证信息

```shell
[root@nagios nagios-4.3.1]# htpasswd -c /usr/local/nagios/etc/htpasswd.users nagios
       New password:   ==> 输入密码，这里我输入的密码是nagios，记住这个密码
R
       Re-type new password:  ==> 确认密码
A
       Adding password for user nagios
```

## 9、apache配置文件参考

  ```shell
  [root@nagios httpd]# grep -v '^$' /etc/httpd/conf/httpd.conf|grep -v '#'
    ServerRoot "/etc/httpd"
    Listen 8080
    LoadModule php7_module        modules/libphp7.so
    Include conf.modules.d/*.conf
    User www
    Group www
    ServerAdmin root@localhost
    <Directory />
        AllowOverride none
        Require all denied
    </Directory>
    DocumentRoot "/var/www/html"
    <Directory "/var/www">
        AllowOverride None
        Require all granted
    </Directory>
    <Directory "/var/www/html">
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    <IfModule dir_module>
        DirectoryIndex index.php index.html
    </IfModule>
    <Files ".ht*">
        Require all denied
    </Files>
    ErrorLog "logs/error_log"
    LogLevel warn
    <IfModule log_config_module>
        LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
        LogFormat "%h %l %u %t \"%r\" %>s %b" common
        <IfModule logio_module>
          LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
        </IfModule>
        CustomLog "logs/access_log" combined
    </IfModule>
    <IfModule alias_module>
        ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
    </IfModule>
    <Directory "/var/www/cgi-bin">
        AllowOverride None
        Options None
        Require all granted
    </Directory>
    <IfModule mime_module>
        TypesConfig /etc/mime.types
        AddType application/x-compress .Z
        AddType application/x-gzip .gz .tgz
        AddHandler application/x-httpd-php .php
        AddType text/html .shtml
        AddOutputFilter INCLUDES .shtml
    </IfModule>
    AddDefaultCharset UTF-8
    <IfModule mime_magic_module>
        MIMEMagicFile conf/magic
    </IfModule>
    EnableSendfile on
    IncludeOptional conf.d/*.conf
  ```

## 10、重新编译一下php，使其直接apache（也就是编译参数加上--with-apxs2）

```shell
   [root@nagios nagios-4.3.1]# cd /software/php-7.1.4/
    [root@nagios php-7.1.4]# ./configure --prefix=/usr/local/php --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --with-mysqli --with-zlib --with-curl --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-openssl --enable-mbstring --enable-xml --enable-session --enable-ftp --enable-pdo -enable-tokenizer --enable-zip --with-apxs2
    [root@nagios php-7.1.4]# make && make install
    [root@nagios php-7.1.4]# cd /etc/httpd/
    [root@nagios httpd]# ll /etc/httpd/modules/libphp7.so 
    -rwxr-xr-x 1 root root 38908880 4月  24 10:34 /etc/httpd/modules/libphp7.so    ===>    可以看到这个模块已经生成
```

## 11、启动apache

```shell
[root@nagios httpd]# systemctl start httpd
[root@nagios httpd]# systemctl enable httpd

```
## 12、开机自启动

 ```shell
  chkconfig nagios on
  /etc/init.d/nagios start
 ```

## 13、在浏览器输入ip:8080/nagios测试nagios-web页面是否可以打开

## 14、安装nagios-plugins插件

```shell
    [root@nagios httpd]# cd /software/
    [root@nagios software]# tar zxvf nagios-plugins-2.2.1.tar.gz
    [root@nagios software]# cd nagios-plugins-2.2.1/
    [root@nagios nagios-plugins-2.2.1]# ./configure --with-nagios-user=nagios --with-nagios-group=nagcmd --enable-perl-modules
    [root@nagios nagios-plugins-2.2.1]# make && make install
```

## 15、选择一个SNMP版本，比如5.7.1或yum安装

```shell
yum安装
                yum -y install net-snmp*
                使用此文件替换/etc/snmp/下的snmpd.conf
                
                
                 
    编译安装
        执行命令./configure --prefix=/usr/local/snmp --with-mib-modules='ucd-snmp/diskio ip-mib/ipv4InterfaceTable'，注意，以上的--with-mib-modules=ucd-snmp/diskio选项，可以让服务器支持磁盘I/O监控。如下图所示：
            回车出现下面问题，可以直接回车而不用回答，系统会采用默认信息，其中日志文件默认安装在/var/log/snmpd.log.数据存贮目录默认存放在/var/net-snmp下
　　　　   1、default version of-snmp-version(3): 
　　　　   2、System Contact Information (@@no.where)（配置该设备的联系信息）:
　　　　   3、System Location (Unknown)(该系统设备的地理位置):
　　　　   4、Location to write logfile (日志文件位置):
　　　　   5、Location to Write persistent(数据存储目录):
             执行编译并安装"make  &&  make install"命令
```
## 16、使用"ls"命令查看/usr/local/snmp目录下是否存在etc目录，如果不存在etc目录，就创建一个

```shell
 找到SNMP源码目录(net-snmp-5.7.1)下EXAMPLE.conf文件，复制EXAMPLE.conf文件到到/usr/local/snmp/etc目录，并重命名为snmpd.conf
        cp EXAMPLE.conf /usr/local/snmp/etc/snmpd.conf
```
## 17、使用vi编辑器打开snmpd.conf文件

 ```shell
   vi /usr/local/snmp/etc/snmpd.conf
    找到【AGENT BEHAVIOUR】，如下图所示：修改如下：添加"agentAddress udp:161"配置项，如下图所示：
    找到【ACTIVE MONITORING】，如下图所示：
　设置访问权限,找到【ACCESS CONTROL】如下图所示：找到【rocommunity public default -V systemonly】，把 -V systemonly去掉，这是设置访问权限的，去掉后能访问全部
 ```

## 18、先杀掉所有snmp进程再启动

  ```shell
 ps aux | grep snmp | grep -v grep |awk '{print $2}'| xargs kill
    netstat -an |grep 161
    /usr/local/snmp/sbin/snmpd -c /usr/local/snmp/etc/snmpd.conf
  ```

## 19、执行以下的几个命令都可以获取到本机的系统名字：

```shell
snmpget -v 2c -c public localhost sysName.0
    snmpget -v 2c -c public 127.0.0.1 sysName.0
    snmpget -v 2c -c public 192.168.1.229 sysName.0
    snmpget -v 2c -c public localhost .1.3.6.1.2.1.1.5.0
    snmpget -v 2c -c public 127.0.0.1 .1.3.6.1.2.1.1.5.0
    snmpget -v 2c -c public 192.168.1.229 .1.3.6.1.2.1.1.5.0
```
## 20、安装net::snmp模块（nagios用户下操作）

 ```shell
  自动安装：
       执行 -MCPAN -e shell
       执行 install Net::SNMP
    手动安装：
        解压：Crypt::DES
                 Digest::MD5
                 Digest::SHA1 
                 Digest::HMAC
                 Net::SNMP    
         cd到目录执行：
                 sudo  perl Makefile.PL
                 sudo  make test
                 sudo  make install
 ```

## 21、安装nagios snmp插件

​       解压后cd目录执行./install

## 22、windows客户端打开snmp功能并配置权限

## 23、编辑配置文件（参考）      

## 24、安装ndoutils

 ```shell
   1）   create user 'nagios'@'%' identified by 'nagios';
        create database nagios;
        grant all on nagios.* to nagios@'%' Identified by "nagios";
        flush privileges;
        导入数据：
                 cd /soft/ndoutils-2.1.3/db
                 ./installdb -u nagios -p nagios -h localhost -d nagios -P 3306
     2）  ./configure --prefix=/usr/local/nagios/ --enable-mysql --with-ndo2db-user=nagios --with-ndo2db-group=nagios
       cp ndo* /usr/local/nagios/etc/
    cp src/{ndomod-4x.o,ndo2db-4x,log2ndo,file2sock} /usr/local/nagios/bin/
    修改配置文件:cd /usr/local/nagios/etc/
                mv ndo2db.cfg-sample ndo2db.cfg
                          vi ndo2db.cfg
       配置文件ndo2db.cfg修改如下:（主要修改三处地方：mysql端口、mysql用户名、mysql用户名密码）
       修改nagios配置文件:/usr/local/nagios/etc/nagios.conf:broker_module=/usr/local/nagios/bin/ndomod-4x.o config_file=/usr/local/nagios/etc/     ndomod.cfg
   添加端口号：vi /etc/service
               tcp/5668
               udp/5668
  
  chown nagios.apache ndo*
  
  
  cp /data/soft/ndoutils-2.1.3/startup/default-init /etc/init.d/ndo2db
   #修改/etc/init.d/ndo2db

NDO2DB_BIN=/usr/local/nagios/bin/ndo2db-4x　

#设置成开机自启
c
    chkconfig ndo2db on


检查nagios语法：/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
 ```

# cpan镜像源配置

cd /root/.cpan/CPAN
vi MyConfig.pm
修改urllist
'urllist' => [q[https://mirror.tuna.tsinghua.edu.cn/CPAN/]],

# 检查nagios语法：

/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
注意事项：
1、安装net::snmp模块时使用nagios用户
2、use_authentication不要设置为0，否则无发使用外部命令 