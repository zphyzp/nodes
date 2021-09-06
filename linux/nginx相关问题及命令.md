# 通过post上传文件过大时，会出现413错误码

前端打开开发者模式，在输出台的位置会出现:<span style="color: rgb(255, 0, 0);">Failed to load resource: the server responded with a status of 413 (Request Entity Too Large)</span>

这是由于上传文件过大引起的，排查服务器是否有使用nginx做反向代理;(我这里是)解决方案:修改nginx配置文件，配置客户端请求大小和缓存大小输入命令:vim /etc/nginx/nginx.conf在http{}中输入: client_max_body_size 8M;(配置请求体缓存区大小, 不配的话) 
重启nginx服务:service nginx restart
或者是nginx -s reload
Nginx reload和restart区别
reload，重新加载的意思，reload会重新加载配置文件，nginx服务不会中断，而且reload时会测试conf语法等，如果出错会rollback用上一次正确配置文件保持正常运行。
restart，重启，会重启nginx服务。这个重启会造成服务一瞬间的中断，当然如果配置文件出错会导致服务启动失败，那就是更长时间的服务中断了。
每次重启之前建议先使用nginx -t 命令查看下，出现一下代码说明正常
nginx: the configuration file /data/nginx-1.17.3/conf/nginx.conf syntax is ok
nginx: configuration file /data/nginx-1.17.3/conf/nginx.conf test is successful
所以，根据不同情况使用不同命令最好不过了。


产生这种原因是因为服务器限制了上传大小
1、nginx服务器的解决办法
修改nginx.conf的值就可以解决了
将以下代码粘贴到nginx.conf内
client_max_body_size 512M

可以选择在http{ }中设置：client_max_body_size 512m; 
也可以选择在server{ }中设置：client_max_body_size 512m;
还可以选择在location{ }中设置：client_max_body_size 512m;
三者有区别
设置到http{}内，控制全局nginx所有请求报文大小
设置到server{}内，控制该server的所有请求报文大小
设置到location{}内，控制满足该路由规则的请求报文大小
同时记得修改php.ini内的上传限制
upload_max_filesize = 512M

2、apache服务器修改
在apache环境中上传较大软件的时候，有时候会出现413错误，出现这个错误的原因，是因为apache的配置不当造成的，找到apache的配置文件目录也就是conf目录，和这个目录平行的一个目录叫conf.d打开这个conf.d，里面有一个php.conf
目录内容如下：

PHP is an HTML-embedded scripting language which attempts to make it # easy for developers to write dynamically generated webpages. # LoadModule php4_module modules/libphp4.so # # Cause the PHP interpreter handle files with a .php extension. # SetOutputFilter PHP SetInputFilter PHP LimitRequestBody 6550000 # # Add index.php to the list of files that will be served as directory # indexes.

误就发生在这个LimitRequestBody配置上，将这个的值改大到超过你的软件大小就可以了
如果没有这个配置文件请将
SetOutputFilter PHP SetInputFilter PHP LimitRequestBody 6550000
写到apache的配置文件里面即可。
3、IIS服务器（Windows Server 2003系统IIS6）
先停止IIS Admin Service服务，然后
找到windows\system32\inesrv\下的metabase.xml，打开，找到ASPMaxRequestEntityAllowed 修改为需要的值，然后重启IIS Admin Service服务
1、在web服务扩展 允许active server pages和在服务器端的包含文档
2、修改各站点的属性 主目录－配置－选项－启用父路径
3、使之可以上传大文档(修改成您想要的大小就可以了，以字节为单位)
c:\WINDOWS\system32\inetsrv\MetaBase.xml
企业版的windows2003在第592行
默认的预设置值 AspMaxRequestEntityAllowed="204800" 即200K
将其加两个0，即改为，现在最大就可以上传20M了。
AspMaxRequestEntityAllowed="20480000"



# map切割access日志和只截取第一个真是ip

```shell
map $http_x_forwarded_for  $clientRealIp {
        ""      $remote_addr;
        ~^(?P<firstAddr>[0-9\.]+),?.*$  $firstAddr;
        }
    include       mime.types;
    default_type  application/octet-stream;
    
    log_format  main  '$remote_addr -"$http_x_forwarded_for"  $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent"';

    log_format  mylog '"$clientRealIp" [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer"';

    map $time_iso8601 $logdate {
        '~^(?<ymd>\d{4}-\d{2}-\d{2})' $ymd;
        default                       'date-not-found';
        }
       
    access_log  logs/access-$logdate.log main;
    access_log  mylogs/access-$logdate.log mylog;
    open_log_file_cache max=10;
```

# 日志分割

```shell
access_log
----vi nginx.conf文件并在http下加入标红内容实现access_log按每天分割----
http {
    include       mime.types;
    default_type  application/octet-stream;
  
  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    map $time_iso8601 $logdate {
        '~^(?<ymd>\d{4}-\d{2}-\d{2})' $ymd;
        default                       'date-not-found';
    }

    access_log  log/access-$logdate.log main;
    open_log_file_cache max=10;

----检查语法----
nginx -t

---重启nginx----
nginx -s stop
nginx


error_log
----已定时脚本方式实现每天分割,vi cut_nginx_error_log----
#!/bin/bash
logs_path="/data/nginx/log/"
pid_path="/data/nginx/log/nginx.pid"
mv ${logs_path}error.log ${logs_path}error_$(date -d "yesterday" +"%Y%m%d").log
kill -USR1 `cat ${pid_path}`
(路径根据实际情况修改)

----设置定时任务，每天零点执行----
0 0 * * *  sh /root/cut_nginx_error_log.sh
```

# 安装

```shell
http://nginx.org/en/download.html
1、环境准备：先安装准备环境
yum install gcc gcc-c++ automake pcre pcre-devel zlip zlib-devel openssl openssl-devel 

2、编译nginx：make
编译是为了检查系统环境是否符合编译安装的要求，比如是否有gcc编译工具，是否支持编译参数当中的模块，并根据开启的参数等生成Makefile文件为下一步做准备：
./configure  --prefix=/usr/local/nginx  --sbin-path=/usr/local/nginx/sbin/nginx --conf-path=/usr/local/nginx/conf/nginx.conf --error-log-path=/var/log/nginx/error.log  --http-log-path=/var/log/nginx/access.log  --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock  --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --http-client-body-temp-path=/var/tmp/nginx/client/ --http-proxy-temp-path=/var/tmp/nginx/proxy/ --http-fastcgi-temp-path=/var/tmp/nginx/fcgi/ --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi --http-scgi-temp-path=/var/tmp/nginx/scgi --with-pcre

make

make install

3、启动关闭
[root@Server1 sbin]# /usr/local/nginx/sbin/nginx/nginx
nginx: [emerg] getpwnam("nginx") failed  #没有nginx用户

[root@Server1 sbin]# /usr/local/nginx/sbin/nginx/nginx
nginx: [emerg] mkdir() "/var/tmp/nginx/client/" failed (2: No such file or directory)  #目录不存在

[root@Server1 sbin]# /usr/local/nginx/sbin/nginx/nginx  #直到没有报错，才算启动完成

重读配置文件和关闭服务：
[root@Server1 local]# /usr/local/nginx/sbin/nginx/nginx  #启动 服务
[root@Server1 local]# /usr/local/nginx/sbin/nginx/nginx   -s  reload  #不停止服务重读配置文件
[root@Server1 local]# /usr/local/nginx/sbin/nginx/nginx -s stop #停止服务  #停止服务
```

