# docker搭建

## 配置docker镜像

```shell
 yum install -y yum-utils
 
 yum-config-manager \
    --add-repo \
http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo    

```

## 安装docker引擎

```shell
#1,安装最新版本
  yum install docker-ce docker-ce-cli containerd.io
#2，根据系统版本号安装
  cat /proc/version
  3.10.0-693.el7.x86_64
  yum install docker-ce-19.03.9-3.el7 docker-ce-cli-19.03.9-3.el7 containerd.io


```

```shell
#查看hellow-world
[root@localhost ~]# docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
0e03bdcc26d7: Pull complete 
Digest: sha256:1a523af650137b8accdaed439c17d684df61ee4d74feac151b5b337bd29e7eec
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

## 配置阿里云镜像加速

```shell
1. 安装／升级Docker客户端
推荐安装1.10.0以上版本的Docker客户端，参考文档 docker-ce

2. 配置镜像加速器
针对Docker客户端版本大于 1.10.0 的用户

您可以通过修改daemon配置文件/etc/docker/daemon.json来使用加速器
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://jg90wp28.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```



# Docker的常用命令

## 帮助命令

```shell 
docker versio #版本信息
docker info   #系统信息
docker 命令 --help  #帮助
```

## 镜像命令

```shell
docker images   #查看本地镜像
docker images -q   #只显示镜像id

```

```shell
docker search mysql  #搜索镜像
--filte=STARS=3000   #搜索收藏大于3000的
[root@localhost ~]# docker search --filter=STARS=3000 mysql
NAME                DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
mysql               MySQL is a widely used, open-source relation…   10269               [OK]                
mariadb             MariaDB is a community-developed fork of MyS…   3794                [OK] 
```

```shell
docker pull mysql  #下载mysql镜像
docker pull mysql:5.7  #指定下载mysql5.7镜像
```

```shell
docker rmi -f ab2f358b8612  #指定images_id删除镜像
docker rmi -f ab2f358b8612 ab2f358b8612 ab2f358b8612 #删除多个镜像
docker rmi -f $(docker images -aq )  #s删除全部镜像
```

```shell
docker pull centos #下载镜像
docker run [可选参数] image
#参数说明
--name-'name' #容器名字
-d  #后台运行
-it #使用交互方式运行
-p  #指定容器映射端口 8080:8080（主机端口：容器端口）

docker run -it centos /bin/bash #启动并进入容器
docker ps #正在运行的容器 
docker ps -a #正在运行的容器 +历史运行过得容器
docker ps -a -n=3 #最近创建的3个容器
docker ps -q  #显示正在运行容器的编号
```

```shell
exit #退出容器
ctrl+p+q #不停止容器退出
```

```shell
docker rm 容器id #不能删除正在运行的容器，-f可以强制删除
docker rm 容器名
docker rm -f $(docker ps -aq) #删除所有容器
docker ps -q -a|xargs docker rm #删除所有容器
```

```shell
docker start 容器id #启动容器
docker stop 容器id #停止容器
docker kill 容器id #强制杀容器
```

## 常用其他命令

```shell
#docker要想使后台运行，必须有个前台运行，否则容器会自动停止

docker logs --help#查看docker日志
docker logs -ft --tail [日志行数] [容器id]

docker top [容器id] #查看容器进程信息

docker inspect [容器id] #查看容器内部结构信息

docker exec -it 37cea55cab6b /bin/bash #进入当前的容器
docker attach 37cea55cab6b #进入当前容器正在执行的终端

docker cp 37cea55cab6b:/home/1212 /data #从容器内容copy文件至容器外

$ docker commit A imageA #将容器commit提交成为一个镜像
 
#使用参数-u指定root用户进入就可以
docker exec -it -u root  040cfdaaca25 /bin/bash

#打包镜像为tar包
docker save -o proxy.tar zabbix/zabbix-proxy-mysql:latest

#将tar包转为镜像
 docker load < proxy.tar 
```

# 作业练习

## docker安装nginx

```shell
docker pull nginx #下载nginx
docker run -d --name nginx01 -p 3344:80 nginx #启动nginx
#-d 后台运行
#--name 容器名字
#-p 映射外部端口
docker exec -it nginx01 /bin/bash #进入docker容器
docker stop ae2feff98a0c #指定容器id停止容器

```

## docker安装tomcat

```shell
docker run -it --rm tomcat:9.0 #用完即删除，测试使用

```

```shell
docker pull tomcat #下载tomcat最新版
docker run -d --name tomcat01 -p 3355:80 tomcat #启动tomcat
docker exec -it tomcat01 /bin/bash #进入tomcat
 #为保证最小的运行环境，docker下载的tomcat为阉割版，默认最小安装，webapps下没有内容。
 
 #部署tomcat项目
 root@c968aa09276e:/usr/local/tomcat/webapps.dist# cp -r * /usr/local/tomcat/webapps/ 
```

## docker安装es+kibana

```shell
docker run -d --name elasticsearch -p 3377:9200 -p 3388:9300 -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms64m -Xmx512m" elasticsearch:7.6.2 
#下载并启动es -e "discovery.type-single-node"指定单实例 -e ES_JAVA_OPTS="-Xms64m -Xms512m"指定内存

docker stats #查看容器资源消耗

curl localhost：3377 #查看es能否访问

```

## docker安装可视化面板portainer

```shell 
docker run -d -p 8088:9000 \
--restart=always -v /var/run/docker.sock:/var/run/docker.sock --privileged=true portainer/portainer
```

远程连接可视化界面管理docker

```shell
1. 编辑docker.service
vim /usr/lib/systemd/system/docker.service
找到 ExecStart字段修改如下
#ExecStart=/usr/bin/dockerd-current -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock 
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
2. 重启docker重新读取配置文件，重新启动docker服务
systemctl daemon-reload
systemctl restart docker
```

# commit镜像

```shell
docker commit #提交一个容器为新副本
#提交自己修改的镜像
docker commit -a="zp" -m="add webapps" c968aa09276e tomcat_comm:1.0

docker images

```

![01](D:\软件\Typora\image\01.PNG)



# 容器数据卷

## 挂在共享卷

挂在是容器内目录的内容和主机目录同步。若挂在前主机目录为空，那么挂在后，容器目录下就算挂在前有内容，挂在后也为空

```shell
#挂在目录  主机目录:容器目录
docker run -d --name nginx02 -p 3333:80 -v /data/nginx02:/etc/nginx nginx
```

![image-20201223223058135](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20201223223058135.png)



## 实战：安装mysql

```shell
docker pull mysql:5.7

#安装运行mysql
 docker run -d -p 3312:3306 -v /data/mysql01/conf:/etc/mysql/conf.d -v /data/mysql01/data/:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 --name mysql01 mysql:5.7
```

## 控制容器读写

```shell
docker run -d -p [端口] --name [容器名] -v [挂载路径]:ro/rw [镜像名] #设置容器为 只读/读写 权限 只读权限时，只能在容器外修改容器内内容

```



# dockerfile

### 创建dockerfile

```shell
FROM centos

VOLUME ["/data/docker_test/vm1":"VOLUME01"]

CMD echo "---end---"
CMD /bin/bash
```

### 运行dockerfile

```shell
[root@localhost docker_test]# docker build -f /data/docker_test/dockerfile01 -t test01/centos:1.0 .
#执行结果输出
Sending build context to Docker daemon   2.56kB
Step 1/4 : FROM centos
 ---> 300e315adb2f
Step 2/4 : VOLUME ["VOLUME01"]
 ---> Running in 50d15c2d249f
Removing intermediate container 50d15c2d249f
 ---> 159922402dc3
Step 3/4 : CMD echo "---end---"
 ---> Running in 680988477f89
Removing intermediate container 680988477f89
 ---> 517f2c411366
Step 4/4 : CMD /bin/bash
 ---> Running in 528e60471f17
Removing intermediate container 528e60471f17
 ---> 99bd18bcc2c5
Successfully built 99bd18bcc2c5
Successfully tagged test01/centos:1.0
```

### 测试CMD命令

```shell
#创建dockerfile02
vi dockerfile02
FROM centos
CMD ["ls","-a"]

#build
 docker build -f dockerfile02 -t cmdtest .
 
#启动后自动执行了CMD的ls -a命令,但是不可以在docker run后面追加新命令
[root@localhost docker_test]# docker run e3e1b35113a8
.
..
.dockerenv
bin
dev
etc
home
lib
lib64
lost+found
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var
[root@localhost docker_test]# 
```

### 测试entrypoint

```shell
#创建dockerfile03
vi dockerfile03
FROM centos
ENTRYPOINT ["ls","-a"]

#build
docker build -f dockerfile03 -t test02 .

#启动后自动执行了ENTRYPOINT的ls -a命令,并在docker run后追加-l
[root@localhost docker_test]# docker run f7807b984d4a -l
total 0
drwxr-xr-x   1 root root   6 Dec 24 14:51 .
drwxr-xr-x   1 root root   6 Dec 24 14:51 ..
-rwxr-xr-x   1 root root   0 Dec 24 14:51 .dockerenv
lrwxrwxrwx   1 root root   7 Nov  3 15:22 bin -> usr/bin
drwxr-xr-x   5 root root 340 Dec 24 14:51 dev
drwxr-xr-x   1 root root  66 Dec 24 14:51 etc
drwxr-xr-x   2 root root   6 Nov  3 15:22 home
lrwxrwxrwx   1 root root   7 Nov  3 15:22 lib -> usr/lib
lrwxrwxrwx   1 root root   9 Nov  3 15:22 lib64 -> usr/lib64
drwx------   2 root root   6 Dec  4 17:37 lost+found
drwxr-xr-x   2 root root   6 Nov  3 15:22 media
drwxr-xr-x   2 root root   6 Nov  3 15:22 mnt
drwxr-xr-x   2 root root   6 Nov  3 15:22 opt
dr-xr-xr-x 179 root root   0 Dec 24 14:51 proc
dr-xr-x---   2 root root 162 Dec  4 17:37 root
drwxr-xr-x  11 root root 163 Dec  4 17:37 run
lrwxrwxrwx   1 root root   8 Nov  3 15:22 sbin -> usr/sbin
drwxr-xr-x   2 root root   6 Nov  3 15:22 srv
dr-xr-xr-x  13 root root   0 Dec 24 14:51 sys
drwxrwxrwt   7 root root 145 Dec  4 17:37 tmp
drwxr-xr-x  12 root root 144 Dec  4 17:37 usr
drwxr-xr-x  20 root root 262 Dec  4 17:37 var
```

### 实战：手写dockerfile创建tomcat镜像

#### 1、准备镜像文件tomcat压缩包，jdk压缩包

![image-20201224231620108](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20201224231620108.png)

#### 2、编写dockerfile文件

```shell
FROM centos
MAINTAINER zp
COPY readme.txt /usr/local/readme.txt
ADD jdk-8u271-linux-x64.tar.gz /usr/local
ADD apache-tomcat-9.0.41.tar.gz /usr/local
RUN yum -y install vim
ENV MYPATH /usr/local
WORKDIR $MYPATH
ENV JAVA_HOME /usr/local/jdk1.8.0_271
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV CATALINA_HOME /usr/local/apache-tomcat-9.0.41
ENV CATALINA_BASH /usr/local/apache-tomcat-9.0.41
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/lib
EXPOSE 8080
CMD /usr/local/apache-tomcat-9.0.41/bin/startup.sh && tail -F /usr/local/apache-tomcat-9.0.41/bin/log/catalina.out
```



#### 3、构建镜像文件

```shell
docker build -f dockerfile03 -t test04 .

Sending build context to Docker daemon  154.6MB
Step 1/15 : FROM centos
 ---> 300e315adb2f
Step 2/15 : MAINTAINER zp
 ---> Running in 8e0ed5afe05c
Removing intermediate container 8e0ed5afe05c
 ---> 998fd9755e23
Step 3/15 : COPY readme.txt /usr/local/readme.txt
 ---> 2fe1fac5d73f
Step 4/15 : ADD jdk-8u271-linux-x64.tar.gz /usr/local
 ---> f55a898b936b
Step 5/15 : ADD apache-tomcat-9.0.41.tar.gz /usr/local
 ---> 29cb706dc504
Step 6/15 : RUN yum -y install vim
 ---> Running in 10973e05aea0
CentOS Linux 8 - AppStream                      3.2 MB/s | 6.3 MB     00:01    
CentOS Linux 8 - BaseOS                         1.2 MB/s | 2.3 MB     00:01    
CentOS Linux 8 - Extras                         2.3 kB/s | 8.6 kB     00:03    
Dependencies resolved.
================================================================================
 Package             Arch        Version                   Repository      Size
================================================================================
Installing:
 vim-enhanced        x86_64      2:8.0.1763-15.el8         appstream      1.4 M
Installing dependencies:
 gpm-libs            x86_64      1.20.7-15.el8             appstream       39 k
 vim-common          x86_64      2:8.0.1763-15.el8         appstream      6.3 M
 vim-filesystem      noarch      2:8.0.1763-15.el8         appstream       48 k
 which               x86_64      2.21-12.el8               baseos          49 k

Transaction Summary
================================================================================
Install  5 Packages

Total download size: 7.8 M
Installed size: 30 M
Downloading Packages:
(1/5): gpm-libs-1.20.7-15.el8.x86_64.rpm        568 kB/s |  39 kB     00:00    
(2/5): vim-filesystem-8.0.1763-15.el8.noarch.rp 764 kB/s |  48 kB     00:00    
(3/5): which-2.21-12.el8.x86_64.rpm             165 kB/s |  49 kB     00:00    
(4/5): vim-enhanced-8.0.1763-15.el8.x86_64.rpm  2.6 MB/s | 1.4 MB     00:00    
(5/5): vim-common-8.0.1763-15.el8.x86_64.rpm    4.9 MB/s | 6.3 MB     00:01    
--------------------------------------------------------------------------------
Total                                           1.8 MB/s | 7.8 MB     00:04     
warning: /var/cache/dnf/appstream-02e86d1c976ab532/packages/gpm-libs-1.20.7-15.el8.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID 8483c65d: NOKEY
CentOS Linux 8 - AppStream                      781 kB/s | 1.6 kB     00:00    
Importing GPG key 0x8483C65D:
 Userid     : "CentOS (CentOS Official Signing Key) <security@centos.org>"
 Fingerprint: 99DB 70FA E1D7 CE22 7FB6 4882 05B5 55B3 8483 C65D
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Installing       : which-2.21-12.el8.x86_64                               1/5 
  Installing       : vim-filesystem-2:8.0.1763-15.el8.noarch                2/5 
  Installing       : vim-common-2:8.0.1763-15.el8.x86_64                    3/5 
  Installing       : gpm-libs-1.20.7-15.el8.x86_64                          4/5 
  Running scriptlet: gpm-libs-1.20.7-15.el8.x86_64                          4/5 
  Installing       : vim-enhanced-2:8.0.1763-15.el8.x86_64                  5/5 
  Running scriptlet: vim-enhanced-2:8.0.1763-15.el8.x86_64                  5/5 
  Running scriptlet: vim-common-2:8.0.1763-15.el8.x86_64                    5/5 
  Verifying        : gpm-libs-1.20.7-15.el8.x86_64                          1/5 
  Verifying        : vim-common-2:8.0.1763-15.el8.x86_64                    2/5 
  Verifying        : vim-enhanced-2:8.0.1763-15.el8.x86_64                  3/5 
  Verifying        : vim-filesystem-2:8.0.1763-15.el8.noarch                4/5 
  Verifying        : which-2.21-12.el8.x86_64                               5/5 

Installed:
  gpm-libs-1.20.7-15.el8.x86_64         vim-common-2:8.0.1763-15.el8.x86_64    
  vim-enhanced-2:8.0.1763-15.el8.x86_64 vim-filesystem-2:8.0.1763-15.el8.noarch
  which-2.21-12.el8.x86_64             

Complete!
Removing intermediate container 10973e05aea0
 ---> 51573c23ea89
Step 7/15 : ENV MYPATH /usr/local
 ---> Running in 8415039b5ad7
Removing intermediate container 8415039b5ad7
 ---> 56055cb48bea
Step 8/15 : WORKDIR $MYPATH
 ---> Running in cdc784083656
Removing intermediate container cdc784083656
 ---> d6da86a7c758
Step 9/15 : ENV JAVA_HOME /usr/local/jdk1.8_271
 ---> Running in 81737cb0cd87
Removing intermediate container 81737cb0cd87
 ---> 7437aca5ffdb
Step 10/15 : ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
 ---> Running in fd1b8882ed5a
Removing intermediate container fd1b8882ed5a
 ---> 858192d12661
Step 11/15 : ENV CATALINA_HOME /usr/local/apache-tomcat-9.0.41
 ---> Running in 6a09d4c1ccc1
Removing intermediate container 6a09d4c1ccc1
 ---> 6a28ccdd2dd0
Step 12/15 : ENV CATALINA_BASH /usr/local/apache-tomcat-9.0.41
 ---> Running in e8e443511f14
Removing intermediate container e8e443511f14
 ---> e8310b4fd8c7
Step 13/15 : ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/lib
 ---> Running in 5faae1ae4640
Removing intermediate container 5faae1ae4640
 ---> 49dae7a45780
Step 14/15 : EXPOSE 8080
 ---> Running in 3fb6c0ef27a6
Removing intermediate container 3fb6c0ef27a6
 ---> d70bccdb2756
Step 15/15 : CMD /usr/local/apache-tomcat-9.0.41/bin/startup.sh && tail -F /usr/local/apache-tomcat-9.0.41/bin/log/catalina.out
 ---> Running in a308c41beeb9
Removing intermediate container a308c41beeb9
 ---> e80373566ac4
Successfully built e80373566ac4
Successfully tagged test04:latest
```

#### 4、运行镜像

```shell
docker run -d -p 9090:8080 --name test_tom -v /data/docker_test/tomcat/vm1:/usr/local/apache-tomcat-9.0.41/webapps/test -v /data/docker_test/tomcat/vm_log1:/usr/local/apache-tomcat-9.0.41/logs test04
```

```shell
#在主机共享的目录加新项目测试
cd /data/docker_test/tomcat/vm1
mkdir WEB-INF
vi web.xml
####插入#####
<?xml version="1.0" encoding="UTF-8"?>
  <web-app xmlns="http://java.sun.com/xml/ns/javaee"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
                               http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
           version="2.5">

  </web-app>


cd ..
vi index.jsp
###插入###
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>zptest</title>
</head>
<body>
Hello World!<br/>
<%
System.out.println("---test web---");
%>
</body>
</html>
```

#访问网页测试

![image-20201226235137961](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20201226235137961.png)

# 发布自己的镜像

## docker hub

http://hub.docker.com

```shell
[root@localhost ~]# docker login -u zpdocker0615

```

# docker网络

## 网络原理

```shell
#查看容器内网络
[root@localhost ~]# docker exec -it tomcat01 ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
46: eth0@if47: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever

#主机可以ping通dokcer容器内部       
[root@localhost ~]# ping 172.17.0.2
PING 172.17.0.2 (172.17.0.2) 56(84) bytes of data.
64 bytes from 172.17.0.2: icmp_seq=1 ttl=64 time=0.428 ms
64 bytes from 172.17.0.2: icmp_seq=2 ttl=64 time=0.067 ms
64 bytes from 172.17.0.2: icmp_seq=3 ttl=64 time=0.175 ms
64 bytes from 172.17.0.2: icmp_seq=4 ttl=64 time=0.057 ms

#主机网卡
[root@localhost ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:a4:b5:ca brd ff:ff:ff:ff:ff:ff
    inet 192.168.123.5/24 brd 192.168.123.255 scope global ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fea4:b5ca/64 scope link 
       valid_lft forever preferred_lft forever
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:63:2b:42:18 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:63ff:fe2b:4218/64 scope link 
       valid_lft forever preferred_lft forever
47: vethe9caad7@if46: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP 
    link/ether f2:6b:8b:46:53:0f brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::f06b:8bff:fe46:530f/64 scope link 
       valid_lft forever preferred_lft forever

#容器内的网卡46对应主机网卡47，两者通过网桥（桥接veth pair）互相通信
```

测试tomcat01和tomcat02是否可以ping通

```shell
#tomcat02可以ping通tomcat01
[root@localhost ~]# docker exec -it tomcat02 ping 172.17.0.2
PING 172.17.0.2 (172.17.0.2) 56(84) bytes of data.
64 bytes from 172.17.0.2: icmp_seq=1 ttl=64 time=0.130 ms
64 bytes from 172.17.0.2: icmp_seq=2 ttl=64 time=0.060 ms
64 bytes from 172.17.0.2: icmp_seq=3 ttl=64 time=0.061 ms
64 bytes from 172.17.0.2: icmp_seq=4 ttl=64 time=0.049 ms
```

## 容器互联

### --link（不推荐使用）

```shell
#通过--link ping容器名
[root@localhost ~]# docker run -d -P --name tomcat03 --link tomcat02 tomcat

[root@localhost ~]# docker exec -it tomcat03 ping tomcat02
PING tomcat02 (172.17.0.3) 56(84) bytes of data.
64 bytes from tomcat02 (172.17.0.3): icmp_seq=1 ttl=64 time=0.122 ms
64 bytes from tomcat02 (172.17.0.3): icmp_seq=2 ttl=64 time=0.054 ms
###正向可以，反向不可以ping通###

#查看docker网络
[root@localhost ~]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
9d7991e8bff1        bridge              bridge              local
0ec0597fbab5        host                host                local
bdc5b8155dab        none                null                local

#查看网卡信息
[root@localhost ~]# docker network inspect 9d7991e8bff1
[
    {
        "Name": "bridge",
        "Id": "9d7991e8bff1183d5716f03f527216d49f18d4b5ef499a593e45972296eff78a",
        "Created": "2020-12-24T21:08:35.132875069+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "2e7b9c4ab34954664a97c217fc74ddf69882a8393582263b895e563291f627e2": {
                "Name": "tomcat02",
                "EndpointID": "443635a061d903844748b1763a31f19fc22d6e79480ba0f1977a9b140a794643",
                "MacAddress": "02:42:ac:11:00:03",
                "IPv4Address": "172.17.0.3/16",
                "IPv6Address": ""
            },
            "adb3ddde2836bdda12e2a59abdd48ee6ee1e02c9418fa08c93dfdab99de6e4f6": {
                "Name": "tomcat03",
                "EndpointID": "631c7c58c45372e6e50e44cb6550d4bf727d9e6f3a9eff43686ce6297e318ae2",
                "MacAddress": "02:42:ac:11:00:04",
                "IPv4Address": "172.17.0.4/16",
                "IPv6Address": ""
            },
            "e39be04d08e5560dc09631cb2ee6be5f5a594f02efd660d0f2dd8ebe4a20b1be": {
                "Name": "tomcat01",
                "EndpointID": "89333677417be23c4aeae7e53db7e669a8a1078b2861cdbf86072d79bd0fe71b",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

### 自定义网络

```shell
#docker0为默认
#自定义网络
#--subnet 192.168.0.0/16(最多支持65535个地址) 192.168.0.0/24（最多支持255个地址）
[root@localhost ~]# docker network create --driver bridge --subnet 192.168.0.0/16 --gateway 192.168.0.1 mynet01
4b03e49bd2a23a60823d9372ab4cba279d4b0d89294b6a71bdd0de8d3ddd008f
[root@localhost ~]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
9d7991e8bff1        bridge              bridge              local
0ec0597fbab5        host                host                local
4b03e49bd2a2        mynet01             bridge              local
bdc5b8155dab        none                null                local
[root@localhost ~]# docker network inspect mynet01
[
    {
        "Name": "mynet01",
        "Id": "4b03e49bd2a23a60823d9372ab4cba279d4b0d89294b6a71bdd0de8d3ddd008f",
        "Created": "2020-12-31T15:47:54.362062882+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "192.168.0.0/16",
                    "Gateway": "192.168.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```

### 使用自定义网络的容器互相ping

```shell
#不使用--links也可使用容器名互相ping通
[root@localhost ~]# docker run -d -P --name tomcat-net-01 --net mynet01 tomcat
643c7bebbb48c6e5558d768d222572e2548fe5ca72fee85178fc1bb23eb19c0c
[root@localhost ~]# docker run -d -P --name tomcat-net-02 --net mynet01 tomcat
9f033db9ede8d2b10b9cf08e2add6e4551824752c99e9da94000c00d1038100f
[root@localhost ~]# docker exec -t tomcat-net-01 ping tomcat-net-02
PING tomcat-net-02 (192.168.0.3) 56(84) bytes of data.
64 bytes from tomcat-net-02.mynet01 (192.168.0.3): icmp_seq=1 ttl=64 time=0.135 ms
64 bytes from tomcat-net-02.mynet01 (192.168.0.3): icmp_seq=2 ttl=64 time=0.061 ms
^C
[root@localhost ~]# docker exec -t tomcat-net-02 ping tomcat-net-01
PING tomcat-net-01 (192.168.0.2) 56(84) bytes of data.
64 bytes from tomcat-net-01.mynet01 (192.168.0.2): icmp_seq=1 ttl=64 time=0.049 ms
64 bytes from tomcat-net-01.mynet01 (192.168.0.2): icmp_seq=2 ttl=64 time=0.050 ms
64 bytes from tomcat-net-01.mynet01 (192.168.0.2): icmp_seq=3 ttl=64 time=0.060 ms
^C
```

## 网络联通

```shell
#新建两个docker0网卡容器
[root@localhost ~]# docker run -d -P --name tomcat01 tomcat
0074c1ca25200198882c8d4eb744b855e6ef93419a3286611b63eb6892232b71
[root@localhost ~]# docker run -d -P --name tomcat02 tomcat
d456a5483a92fa9ca259ed2510d43e3c6b53f93d8b7b639584264e4bea6cabd0

#使用docker network connect 打通基于两个网段的容器的网络
[root@localhost ~]# docker network connect mynet01 tomcat01

#查看mynet01发现tomcat01已经加入到mynet01里
[root@localhost ~]# docker network inspect mynet01
[
    {
        "Name": "mynet01",
        "Id": "4b03e49bd2a23a60823d9372ab4cba279d4b0d89294b6a71bdd0de8d3ddd008f",
        "Created": "2020-12-31T15:47:54.362062882+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "192.168.0.0/16",
                    "Gateway": "192.168.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "0074c1ca25200198882c8d4eb744b855e6ef93419a3286611b63eb6892232b71": {
                "Name": "tomcat01",
                "EndpointID": "4283692564c2f3677c76af0b67e0c2f0ef68a536d7af050e62f8f1918d178821",
                "MacAddress": "02:42:c0:a8:00:04",
                "IPv4Address": "192.168.0.4/16",
                "IPv6Address": ""
            },
            "643c7bebbb48c6e5558d768d222572e2548fe5ca72fee85178fc1bb23eb19c0c": {
                "Name": "tomcat-net-01",
                "EndpointID": "4e6e8898b9186f510d51534480aa1f490678652ebcba57d7eeef27b801b9cc89",
                "MacAddress": "02:42:c0:a8:00:02",
                "IPv4Address": "192.168.0.2/16",
                "IPv6Address": ""
            },
            "9f033db9ede8d2b10b9cf08e2add6e4551824752c99e9da94000c00d1038100f": {
                "Name": "tomcat-net-02",
                "EndpointID": "364d41d0b19c667dbbfbc657657160b6c0567bec3e4c31cb38a030d898a1b6be",
                "MacAddress": "02:42:c0:a8:00:03",
                "IPv4Address": "192.168.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]

#测试
[root@localhost ~]# docker exec -it tomcat01 ping tomcat-net-01
PING tomcat-net-01 (192.168.0.2) 56(84) bytes of data.
64 bytes from tomcat-net-01.mynet01 (192.168.0.2): icmp_seq=1 ttl=64 time=0.059 ms
64 bytes from tomcat-net-01.mynet01 (192.168.0.2): icmp_seq=2 ttl=64 time=0.053 ms
64 bytes from tomcat-net-01.mynet01 (192.168.0.2): icmp_seq=3 ttl=64 time=0.056 ms
^C
--- tomcat-net-01 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2ms
rtt min/avg/max/mdev = 0.053/0.056/0.059/0.002 ms
[root@localhost ~]# docker exec -it tomcat-net-01 ping tomcat01
PING tomcat01 (192.168.0.4) 56(84) bytes of data.
64 bytes from tomcat01.mynet01 (192.168.0.4): icmp_seq=1 ttl=64 time=0.084 ms
64 bytes from tomcat01.mynet01 (192.168.0.4): icmp_seq=2 ttl=64 time=0.087 ms
64 bytes from tomcat01.mynet01 (192.168.0.4): icmp_seq=3 ttl=64 time=0.082 ms
64 bytes from tomcat01.mynet01 (192.168.0.4): icmp_seq=4 ttl=64 time=0.056 ms
^C
--- tomcat01 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 0.056/0.077/0.087/0.013 ms
```

# 修改容器数据默认位置

```shell
docker安装之后默认的服务数据存放根路径为/var/lib/docker目录下，var目录默认使用的是根分区的磁盘空间；所以这是非常危险的事情；随着我们镜像、启动的容器实例开始增多的时候，磁盘所消耗的空间也会越来越大，所以我们必须要做数据迁移和修改docker服务的默认存储位置路径；有多种方式是可以修改docker默认存储目录路径的，但是最好是在docker安装完成后，第一时间便修改docker的默认存储位置路径为其他磁盘空间较大的目录(一般企业中为/data目录)，规避迁移数据过程中所造成的风险。

#（1）创建docker容器存放的路径
 mkdir -p /data/docker/lib

#（2）停止Docker服务并迁移数据到新目录
systemctl stop docker.service
rsync -avz /var/lib/docker/ /data/docker/lib/

#（3）创建Docker配置文件
mkdir -p /etc/systemd/system/docker.service.d/ 
vim /etc/systemd/system/docker.service.d/devicemapper.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd  --graph=/data/docker/lib/

#（4）重启Docker服务
 systemctl daemon-reload 
 systemctl restart docker

#（5）查看现在容器存放的目录
  docker info | grep "Dir"
  Docker Root Dir: /data/docker/lib
```







