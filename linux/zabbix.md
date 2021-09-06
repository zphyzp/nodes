# zabbix3.2.3安装部署

## 1准备环境

   centos6.9、nginx-1.7.13、php-5.6.31、mysq-5.7

## 2安装nginx    

```shell
      nginx配置：
        server {
        listen       80;
        server_name  192.166.110.114;
        root         html;
        index        index.html index.htm index.php;
        charset utf-8;
   
   location ~ \.php$ {
    root         html;
    index        index.html index.htm index.php;
    fastcgi_pass   127.0.0.1:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
    include        fastcgi_params;
    }
```

## 3安装mysql数据库

## 4编译安装php-5.6.31

  ```shell
 tar xf php-5.6.30.tar.gz

   yum安装php依赖包
   yum -y install libxml2 libxml2-devel bzip2 bzip2-devel curl curl-devel libjpeg-devel libpng libphp-devel libxslt-devel net-snmp-devel readline-devel aspell-deve unixODBC-devel libicu-devel libc-client-devel freetype-devel libvpx-devel libXpm-devel libvpx-devel enchant-devel libcurl-devel libc-client-devel openldap openldap-devel libpng libpng-devel

   编译安装php
   ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-bz2 --with-curl --enable-sockets --disable-ipv6 --with-gd --with-jpeg-dir=/usr/local --with-png-dir=/usr/local --with-freetype-dir=/usr/local --enable-gd-native-ttf --with-iconv-dir=/usr/local --enable-mbstring --enable-calendar --with-gettext --with-libxml-dir=/usr/local --with-zlib --with-pdo-mysql=mysqlnd --with-mysqli=mysqlnd --with-mysql=mysqlnd --enable-dom --enable-xml --enable-fpm --with-libdir=lib64 --enable-bcmath

   make && make install

   cp php.ini-development /usr/local/php/etc/php.ini

   cd /usr/local/php/etc/

   cp php-fpm.conf.default php-fpm.conf

   修改php的配置文件 vi /usr/local/php/etc/php.ini
   372 max_execution_time = 300
   382 max_input_time = 300
   393 memory_limit = 256M
   660 post_max_size = 32M
   702 always_populate_raw_post_data = -1
   820 upload_max_filesize = 16M
   936 date.timezone = Asia/Shanghai

   调整php进程用户与nginx一致，若使用root，则启动php是加上-R
   vi /usr/local/php5/etc/php-fpm.conf
   149 user = root
   150 group = root

   启动PHP：/usr/local/php/sbin/php-fpm
   root启动：/usr/local/php/sbin/php-fpm -R
  ```

## 5创建zabbix数据库

   ```shell
mysql> CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;
   mysql> GRANT ALL PRIVILEGES ON *.* TO 'zabbix'@'localhost' IDENTIFIED BY 'zabbix'; 
   mysql> GRANT ALL PRIVILEGES ON *.* TO 'zabbix'@'IP地址' IDENTIFIED BY 'zabbix'; 
   mysql> flush privileges;  

   yum install httpd libxml2-devel net-snmp-devel libcurl-devel library library-devel

   tar xf zabbix-3.2.4.tar.gz

   cd到zabbix-3.2.4/database/mysql目录下执行：
   /usr/bin/mysql -uzabbix -pzabbix zabbix < schema.sql
   /usr/bin/mysql -uzabbix -pzabbix zabbix < images.sql
   /usr/bin/mysql -uzabbix -pzabbix zabbix < data.sql
   导入data.sql时如遇到报错，首先确认导入顺序是否如上，若导入顺序正确，则进入mysql执行：
   alter table sysmaps_elements drop foreign key c_sysmaps_elements_2;
   ```

## 6编译安装zabbix   

 ```shell
  ./configure --prefix=/usr/local/zabbix --sysconfdir=/etc/zabbix/ --enable-server --enable-agent --with-net-snmp --with-libcurl --with-mysql --with-libxml2

   Make && make install

   vim /etc/zabbix/zabbix-server.conf
   77 DBHost=localhost
   87 DBName=zabbix
   103 DBUser=zabbix
   111 DBPassword=zabbix
   299 ListenIP=127.0.0.1,192.168.37.132

   软连接
   ln -s /usr/local/zabbix/sbin/ /usr/sbin/

   cp misc/init.d/fedora/core/zabbix_* /etc/init.d/
   chmod +x /etc/init.d/zabbix_*
   mkdir /data/nginx/html/zabbix
   cp -r frontends/php  /data/nginx/html/zabbix
   cd /data/nginx/html/
   mv php zabbix

   启动zabbix
   /etc/init.d/zabbix_server start

   访问
   IP地址/zabbix
 ```

# zabbix 远程获取脚本权限不足

## 一、使用zabbix_get工具测试

1、登录zabbix服务器端，进入到/usr/local/zabbix/bin（安装zabbix_get工具目录）目录下，找到zabbix_get，执行以下命令：
./zabbix_get -s 192.168.154.203 -k process.mqtt.memory

备注：
-s：客户端IP地址
-k：客户端自定义的key值
执行命令后发现报错：

2、登录到zabbix客户端，进入到自定义脚本的目录下，通过执行脚本获取key值的结果，结果显示能够正常响应。

3、切换到zabbix用户执行步骤二中的命令，发现zabbix用户确实是没有权限的。

## 二、赋予zabbix权限

```shell
1、使用root账户登录客户端，进入到/etc目录下，执行以下命令：
sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' sudoers

sed -i '99a zabbix  ALL=(ALL)       NOPASSWD:ALL' sudoers

备注：以上命令代表zabbix-agent可以不凭借密码直接执行命令，zabbix用户权限相对可能会有点大，操作需慎重考虑。
2、修改/etc/passwd文件中zabbix那行：
/var/lib/zabbix改为/home/zabbix
/bin/false改为/bin/bash

3、home目录下创建zabbix目录，并修改zabbix目录权限
cd /home

mkdir zabbix

chown -R zabbix.zabbix zabbix

4、拷贝脚本到/home/zabbix目录下，修改脚本的权限
cp /usr/local/zabbix/scripts/processstatus.sh /home/zabbix/

cd /home/zabbix

chmod u+x processstatus.sh

chown -R zabbix.zabbix processstatus.sh

chmod +s /bin/netstat
```

## 三、修改客户端配置文件

1、cd进入/usr/local/zabbix/etc目录，修改zabbix_agentd.conf中脚本的路径为/homezabbix/processstatus.sh

2、重启客户端，让配置生效
service zabbix_agentd restart

3、再次通过zabbix服务器端测试发现结果可以获取了，界面端的状态也处于启动状态。