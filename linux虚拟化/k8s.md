# k8s基本框架

## 基础概念

资源清单：资源   掌握资源清单的语法   编写 Pod   掌握 Pod 的生命周期***

Pod 控制器：掌握各种控制器的特点以及使用定义方式

服务发现：掌握 SVC 原理及其构建方式

存储：掌握多种存储类型的特点 并且能够在不同环境中选择合适的存储方案（有自己的简介）

调度器：掌握调度器原理   能够根据要求把Pod 定义到想要的节点运行

安全：集群的认证  鉴权   访问控制 原理及其流程 

HELM：Linux yum    掌握 HELM 原理   HELM 模板自定义  HELM 部署一些常用插件

运维：修改Kubeadm 达到证书可用期限为 10年     能够构建高可用的 Kubernetes 集群

服务分类
	有状态服务：DBMS  
	无状态服务：LVS APACHE	
高可用集群副本数据最好是 >= 3 奇数个
	

## 组件说明	

APISERVER：所有服务访问统一入口
CrontrollerManager：维持副本期望数目
Scheduler：负责介绍任务，选择合适的节点进行分配任务
ETCD：键值对数据库  储存K8S集群所有重要信息（持久化）
Kubelet：直接跟容器引擎交互实现容器的生命周期管理
Kube-proxy：负责写入规则至 IPTABLES、IPVS 实现服务映射访问的
COREDNS：可以为集群中的SVC创建一个域名IP的对应关系解析
DASHBOARD：给 K8S 集群提供一个 B/S 结构访问体系
INGRESS CONTROLLER：官方只能实现四层代理，INGRESS 可以实现七层代理
FEDERATION：提供一个可以跨集群中心多K8S统一管理功能
PROMETHEUS：提供K8S集群的监控能力
ELK：提供 K8S 集群日志统一分析介入平台
	


# 部署

## kubeadm部署k8s-1.15.1

### 初始化系统

```shell
hostnamectl set-hostname k8s-master01
hostnamectl set-hostname k8s-node01	
hostnamectl set-hostname k8s-node02	
```

### 安装依赖

```shell
yum install -y conntrack ntpdate ntp ipvsadm ipset jq iptables curl sysstat libseccomp wget vim net-tools git
```

### 设置防火墙为 Iptables 并设置空规则

```shell
systemctl stop firewalld && systemctl disable firewalld
yum -y install iptables-services && systemctl start iptables && systemctl enable iptables && iptables -F && service iptables save
```

### 关闭 SELINUX

```shell
swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
```

### 调整内核参数，对于 K8S

```shell
cat > kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
vm.swappiness=0 # 禁止使用 swap 空间，只有当系统 OOM 时才允许使用它
vm.overcommit_memory=1 # 不检查物理内存是否够用
vm.panic_on_oom=0 # 开启 OOM
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF

cp kubernetes.conf /etc/sysctl.d/kubernetes.conf

sysctl -p /etc/sysctl.d/kubernetes.conf
```

### 调整系统时区

```shell
# 设置系统时区为 中国/上海
timedatectl set-timezone Asia/Shanghai
# 将当前的 UTC 时间写入硬件时钟
timedatectl set-local-rtc 0
# 重启依赖于系统时间的服务
systemctl restart rsyslog
systemctl restart crond
```

### 关闭系统不需要服务

```shell
systemctl stop postfix && systemctl disable postfix
```

### 设置 rsyslogd 和 systemd journald

```shell
mkdir /var/log/journal    # 持久化保存日志的目录
mkdir /etc/systemd/journald.conf.d

cat > /etc/systemd/journald.conf.d/99-prophet.conf <<EOF
[Journal]
# 持久化保存到磁盘
Storage=persistent
# 压缩历史日志
Compress=yes
SyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000
# 最大占用空间 10G
SystemMaxUse=10G
# 单日志文件最大 200M
SystemMaxFileSize=200M
# 日志保存时间 2 周
MaxRetentionSec=2week
# 不将日志转发到 syslog
ForwardToSyslog=no
EOF

systemctl restart systemd-journald
```

### 升级系统内核为 4.18

CentOS 7.x 系统自带的 3.10.x 内核存在一些 Bugs，导致运行的 Docker、Kubernetes 不稳定，例如： rpm -Uvh
http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

#### 方法1

此方法安装的是最新版本内核，会出现不存在conntrack_ipv4模块现象，导致ipvs功能无法使用

```shell
##
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
# 安装完成后检查 /boot/grub2/grub.cfg 中对应内核 menuentry 中是否包含 initrd16 配置，如果没有，再安装
一次！
yum --enablerepo=elrepo-kernel install -y kernel-lt
# 设置开机从新内核启动
grub2-set-default 'CentOS Linux (4.18.12-1.el7.elrepo.x86_64) 7 (Core)'
```

#### 方法2

下载4.18版本内核，手动安装

```shell
rpm -ivh kernel-ml-4.18.12-1.el7.elrepo.x86_64.rpm
# 设置开机从新内核启动
grub2-set-default 'CentOS Linux (4.18.12-1.el7.elrepo.x86_64) 7 (Core)'

##重启机器并使用uname -r查看当前内核版本
```

### kube-proxy开启ipvs的前置条件

```shell
modprobe br_netfilter

cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```

### 安装 Docker 软件

```shell
yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager \
--add-repo \
http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum update -y && yum install -y docker-ce

systemctl start docker
systemctl enable docker

# 配置 daemon.
cat > /etc/docker/daemon.json <<EOF
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
  },
 "insecure-registries": ["https://hub.zptest.com"],
 "registry-mirrors": ["https://jg90wp28.mirror.aliyuncs.com"]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# 重启docker服务
systemctl daemon-reload && systemctl restart docker && systemctl enable docker

grub2-set-default 'CentOS Linux (4.18.12-1.el7.elrepo.x86_64) 7 (Core)'

重启机器reboot
```

### 安装 Kubeadm （主从配置）

```shell
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum -y install kubeadm-1.15.1 kubectl-1.15.1 kubelet-1.15.1

systemctl enable kubelet.service
```

### 查看kubeadm所需镜像

```shell
root@k8s-master01 ~]# kubeadm config images list
W0130 13:22:29.322371    1509 version.go:98] could not fetch a Kubernetes version from the internet: unable to get URL "https://dl.k8s.io/release/stable-1.txt": Get https://storage.googleapis.com/kubernetes-release/release/stable-1.txt: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
W0130 13:22:29.322476    1509 version.go:99] falling back to the local client version: v1.15.1
k8s.gcr.io/kube-apiserver:v1.15.1
k8s.gcr.io/kube-controller-manager:v1.15.1
k8s.gcr.io/kube-scheduler:v1.15.1
k8s.gcr.io/kube-proxy:v1.15.1
k8s.gcr.io/pause:3.1
k8s.gcr.io/etcd:3.3.10
k8s.gcr.io/coredns:1.3.1
```

### 通过阿里云拉取镜像(注意镜像版本)

```shell
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.15.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.15.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.15.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.15.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1
```

### 下载后的镜像打上tag，来符合kudeadm init初始化时候的要求

```shell
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.15.1 k8s.gcr.io/kube-apiserver:v1.15.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.15.1 k8s.gcr.io/kube-controller-manager:v1.15.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.15.1 k8s.gcr.io/kube-scheduler:v1.15.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.15.1 k8s.gcr.io/kube-proxy:v1.15.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1 k8s.gcr.io/pause:3.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10 k8s.gcr.io/etcd:3.3.10
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1 k8s.gcr.io/coredns:1.3.1
```

### 初始化主节点

```shell
kubeadm config print init-defaults > kubeadm-config.yaml

localAPIEndpoint:
advertiseAddress: 192.168.66.10
kubernetesVersion: v1.15.1
networking:
podSubnet: "10.244.0.0/16"
serviceSubnet: 10.96.0.0/12
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
featureGates:
 SupportIPVSProxyMode: true
mode: ipvs

kubeadm init --config=kubeadm-config.yaml --experimental-upload-certs | tee kubeadm-init.log
```

### 加入主节点以及其余工作节点

```shell
more kubeadm-init.log 

##根据日志内容执行以下命令##
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

##创建k8s初始化目录##
mkdir install-k8s
cd install-k8s
mkdir mkdir
mkdir plugin
cd 
mv kubeadm-init.log  kubeadm-config.yaml install-k8s/core/
cd /root/install-k8s/plugin
mkdir flannel
```

### 部署网络	

```shell
##新版本kube flannel方法
wget https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel.yml

kubectl create -f kube-flannel.yml

##k8s-1.15.1方法
访问https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel.yml

打开 kube-flannel-old.yaml 复制里面的内容

回到flannel目录创建kube-flannel.yml并将内容粘贴至改文件后执行：
kubectl create -f kube-flannel.yml 
```

### 将子节点加入到master

```shell
到各子节点执行:
kubeadm join 192.168.160.10:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:8b540afc0a11104efda3982bf30d3c3c77b7925d790f86f7e2b33efbee7b2392
```

### 查看命令

```shell
##查看各节点状态
kubectl get node -o wide

##查看系统名称空间（kube-system）下各组件、pod状态
kubectl get pod -n kube-system
```



## 配置harbor私服	

### 修改每个节点的/etc/docker/daemon.json 

```shell
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
  },
  "insecure-registries": ["https://hub.zptest.com"]
}
```

### 重启docker 

### 下载对应版本的docker-compose

```shell
curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

cat > /etc/docker/daemon.json <<EOF
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
  },
 "insecure-registries": ["https://hub.zptest.com"]
}
EOF
```

### 下载对应版本的harbor

```shell
#下载、解压、安装
https://github.com/goharbor/harbor/releases/download/v1.2.0/harbor-offline-installer-v1.2.0.tgz2

#修改域名及协议
vi /usr/local/harbor/harbor.cfg

hostname = hub.zptest.com
ui_url_protocol = https
certificate: /data/cert/server.crt
private_key: /data/cert/server.key
location: /data/log/harbor

#创建目录
mkdir -p /data/cert/
```

### 修改harbor-v2.0的默认密码

```shell
#进入到harbor-db容器
docker exec -it harbor-db /bin/bash

#登入到postgresql
psql -h postgresql -d postgres -U postgres  #这要输入默认密码：root123 。
psql -U postgres -d postgres -h 127.0.0.1 -p 5432  #或者用这个可以不输入密码。

#切换至harbor数据库
\c registry

#查看harbor用户
select * from harbor_user;

#更新密码为harbor12345
update harbor_user set password='c999cbeae74a90282c8fa7c48894fb00',salt='nmgxu7a5ozddr0z6ov4k4f7dgnpbvqky'  where username='admin';

#推出
\q     退出postgresql
exit  退出容器

#重启harbor
docker-compose down
docker-compose up -d
```

### 创建 https 证书以及配置相关目录权限

```shell
openssl genrsa -des3 -out server.key 2048 #执行后输入密码

openssl req -new -key server.key -out server.csr

Enter pass phrase for server.key: #输入刚才的密码
139686179162000:error:28069065:lib(40):UI_set_result:result too small:ui_lib.c:831:You must type in 4 to 1023 characters
Enter pass phrase for server.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN #国家
State or Province Name (full name) []:BJ #省份
Locality Name (eg, city) [Default City]:BJ #城市
Organization Name (eg, company) [Default Company Ltd]:ZPTEST #机构
Organizational Unit Name (eg, section) []:ZPTEST #姓名
Common Name (eg, your name or your server's hostname) []:hub.zptest.com #仓库域名
Email Address []:252275406@qq.com #邮箱

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

cp server.key server.key.org

openssl rsa -in server.key.org -out server.key

openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

chmod -R 777 /data/cert
```

### 安装harbor

```shell
cd /usr/local/harbor
./install.sh

#修改hosts文件v
[root@k8s-master01 ~]# more /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.160.10 k8s-master01
192.168.160.11 k8s-node01
192.168.160.12 k8s-node02
192.168.160.100 hub.zptest.com
```

### 访问harbor

本机修改hosts文件，通过网页访问hub.zptest.com.

账号默认admin 密码Harbor12345   #harbor.cfg文件中已声明

### docker连接镜像

```shell
#先去docker官网pull一个hello-world的测试镜像，并改标签
docker pull hello-world
docker tag hub.zptest.com/library/myapp:v1 hello-worl:lastest

#登录自己的harbor，并上传该镜像
docker login https://hub.zptest.com
docker push hub.zptest.com/library/myapp:v1

#创建镜像（由于是测试镜像启动失败，也不建议以此方式启动pod）
kubectl run tomcat-deployment --image=tomcat_test:v1 --port=8080 --replicas=2
```

### 查看测试容器状态

```shell
#为deployment创建一个svc，映射端口为30000
kubectl expose deployment tomcat-deployment  --port=30000 --target-port=8080

#查看svc
[root@k8s-master1 ~]# kubectl get svc
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
kubernetes          ClusterIP   10.96.0.1        <none>        443/TCP     2d22h
tomcat-deployment   ClusterIP   10.100.218.219   <none>        30000/TCP   5m28s

#查看ipvs负载的地址
[root@k8s-master1 ~]# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn  
TCP  10.100.218.219:30000 rr
  -> 10.244.2.2:8080              Masq    1      0          0         
  -> 10.244.3.2:8080              Masq    1      0          0 

#修改nodeip访问测试
kubectl edit svc tomcat-deployment
#修改 type: NodePort
```

### harbor扩展

#### 指定harborlog存放位置

```shell
#先关闭harbor
docker-compose down -v

#编辑harbor的yml文件
vi /data/soft/harbor/harbor.yml

#修改log的存放目录，需提前创建
location: /var/log/harbor
修改为
location: /data/log/harbor

#当前目录执行prepare脚本
./prepare

#启动harbor
docker-compose up -d
```



## kubeadm高可用部署k8s-1.15.1

### 初始化系统

```shell
hostnamectl set-hostname k8s-master1
hostnamectl set-hostname k8s-master2
hostnamectl set-hostname k8s-master3
hostnamectl set-hostname k8s-node1	
hostnamectl set-hostname k8s-node2	
```

### 安装依赖

```shell
yum install -y conntrack ntpdate ntp ipvsadm ipset jq iptables curl sysstat libseccomp wget vim net-tools git
```

### 设置防火墙为 Iptables 并设置空规则

```shell
systemctl stop firewalld && systemctl disable firewalld
yum -y install iptables-services && systemctl start iptables && systemctl enable iptables && iptables -F && service iptables save
```

### 关闭 SELINUX

```shell
swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
```

### 调整内核参数，对于 K8S

```shell
cat > kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF

cp kubernetes.conf /etc/sysctl.d/kubernetes.conf

sysctl -p /etc/sysctl.d/kubernetes.conf
```

### 调整系统时区

```shell
# 设置系统时区为 中国/上海
timedatectl set-timezone Asia/Shanghai
# 将当前的 UTC 时间写入硬件时钟
timedatectl set-local-rtc 0
# 重启依赖于系统时间的服务
systemctl restart rsyslog
systemctl restart crond
```

### 关闭系统不需要服务

```shell
systemctl stop postfix && systemctl disable postfix
```

### 设置 rsyslogd 和 systemd journald

```shell
mkdir /var/log/journal    # 持久化保存日志的目录
mkdir /etc/systemd/journald.conf.d

cat > /etc/systemd/journald.conf.d/99-prophet.conf <<EOF
[Journal]
# 持久化保存到磁盘
Storage=persistent
# 压缩历史日志
Compress=yes
SyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000
# 最大占用空间 10G
SystemMaxUse=10G
# 单日志文件最大 200M
SystemMaxFileSize=200M
# 日志保存时间 2 周
MaxRetentionSec=2week
# 不将日志转发到 syslog
ForwardToSyslog=no
EOF

systemctl restart systemd-journald
```

### 升级系统内核为 4.18

CentOS 7.x 系统自带的 3.10.x 内核存在一些 Bugs，导致运行的 Docker、Kubernetes 不稳定，例如： rpm -Uvh
http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

#### 方法1

此方法安装的是最新版本内核，会出现不存在conntrack_ipv4模块现象，导致ipvs功能无法使用

```shell
##
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
# 安装完成后检查 /boot/grub2/grub.cfg 中对应内核 menuentry 中是否包含 initrd16 配置，如果没有，再安装
一次！
yum --enablerepo=elrepo-kernel install -y kernel-lt
# 设置开机从新内核启动
grub2-set-default 'CentOS Linux (4.18.12-1.el7.elrepo.x86_64) 7 (Core)'
```

#### 方法2

下载4.18版本内核，手动安装

```shell
wget https://ossjc-1252545319.cos.ap-shanghai.myqcloud.com/other/linux/kernel-ml-4.18.9/kernel-ml-4.18.9.tar.gz
rpm -ivh kernel-ml-4.18.9-1.el7.elrepo.x86_64.rpm
# 设置开机从新内核启动
grub2-set-default 'CentOS Linux (4.18.9-1.el7.elrepo.x86_64) 7 (Core)'

##重启机器并使用uname -r查看当前内核版本
```

### kube-proxy开启ipvs的前置条件

```shell
modprobe br_netfilter

cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```

### 安装 Docker 软件

```shell
yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager \
--add-repo \
http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum update -y && yum install -y docker-ce

systemctl start docker
systemctl enable docker

# 配置 daemon.
cat > /etc/docker/daemon.json <<EOF
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
  },
 "insecure-registries": ["https://hub.zptest.com"],
 "registry-mirrors": ["https://jg90wp28.mirror.aliyuncs.com"]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# 重启docker服务
systemctl daemon-reload && systemctl restart docker && systemctl enable docker

grub2-set-default 'CentOS Linux (4.18.12-1.el7.elrepo.x86_64) 7 (Core)'

重启机器reboot
```

### 安装 Kubeadm （主从配置）

```shell
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum -y install kubeadm-1.15.1 kubectl-1.15.1 kubelet-1.15.1

systemctl enable kubelet.service
```

### 查看kubeadm所需镜像

```shell
root@k8s-master01 ~]# kubeadm config images list
W0130 13:22:29.322371    1509 version.go:98] could not fetch a Kubernetes version from the internet: unable to get URL "https://dl.k8s.io/release/stable-1.txt": Get https://storage.googleapis.com/kubernetes-release/release/stable-1.txt: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
W0130 13:22:29.322476    1509 version.go:99] falling back to the local client version: v1.15.1
k8s.gcr.io/kube-apiserver:v1.15.1
k8s.gcr.io/kube-controller-manager:v1.15.1
k8s.gcr.io/kube-scheduler:v1.15.1
k8s.gcr.io/kube-proxy:v1.15.1
k8s.gcr.io/pause:3.1
k8s.gcr.io/etcd:3.3.10
k8s.gcr.io/coredns:1.3.1
```

### 通过阿里云拉取镜像(注意镜像版本)

```shell
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.15.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.15.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.15.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.15.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1
```

### 下载后的镜像打上tag，来符合kudeadm init初始化时候的要求

```shell
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.15.1 k8s.gcr.io/kube-apiserver:v1.15.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.15.1 k8s.gcr.io/kube-controller-manager:v1.15.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.15.1 k8s.gcr.io/kube-scheduler:v1.15.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.15.1 k8s.gcr.io/kube-proxy:v1.15.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1 k8s.gcr.io/pause:3.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10 k8s.gcr.io/etcd:3.3.10
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1 k8s.gcr.io/coredns:1.3.1
```

### 下载负载均衡haproxy和keeplived镜像

#### 以下所有操作仅在master1上操作

```shell
#现在k8s-master1执行
mkdir -p /usr/local/kubernetes/install
docker load -i haproxy.tar
docker load -i keepalived.tar

tar -xvf start.keep.tar.gz
mv data /
cd /data/lb
cp haproxy.cfg /root/ #备份一下，稍后需要修改
vi etc/haproxy.cfg 
server rancher01 192.168.160.10:6443 #修改该行为本机ip
cd /data/lb
vi start-haproxy.sh
#修改如下内容
MasterIP1=192.168.160.10
MasterIP2=192.168.160.11
MasterPort=6443

#执行
./ start-haproxy.sh

vi start-keepalived.sh
#修改如下内容
VIRTUAL_IP=192.168.160.111  #VIP
INTERFACE=ens33 #本机网卡
CHECK_PORT=6444

#执行ip addr查看到如下信息证明vip添加成功
   inet 192.168.160.111/24 scope global secondary ens33
       valid_lft forever preferred_lft forever

#将data传到k8s-master2
scp -r /data root@k8s-master2:/
```

### 初始化k8s

```shell
cd /usr/local/kubernetes/install

kubeadm config print init-defaults > kubeadm-config.yaml

vi kubeadm-config.yaml
#修改如下信息
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.160.10   #
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: k8s-master1
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controlPlaneEndpoint: "192.168.160.111:6444"   #
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: v1.15.1
networking:
  dnsDomain: cluster.local
  podSubnet: "10.244.0.0/16"       #
  serviceSubnet: 10.96.0.0/12
scheduler: {}
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1   #
kind: KubeProxyConfiguration                    #
featureGates:                                   #
 SupportIPVSProxyMode: true                        #
mode: ipvs                                   #


#执行初始化操作
kubeadm init --config=kubeadm-config.yaml --experimental-upload-certs | tee kubeadm-init.log

#查看日志输出信息执行以下操作（根据日志内容操作，以下仅为范例）
 mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### 以下所有操作仅在master2上操作

```shell
mkdir -p /usr/local/kubernetes/install
docker load -i haproxy.tar
docker load -i keepalived.tar

[root@k8s-master2 install]# cd /data/lb/
[root@k8s-master2 lb]# ./start-haproxy.sh 
[root@k8s-master2 lb]# ./start-keepalived.sh 

#根据master1节点初始化输出的日志执行如下命令（不要复制错了，与加入工作节点的命令相似，复制第一个命令）
  kubeadm join 192.168.160.111:6444 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:9323b76c0269e42cc4d0407ef1299e8b0598fcade168422b439a93a768b88b7b \
    --control-plane --certificate-key eba74ce3dc0d1accd1ad3297f8692897b949608d0f12c4af7975eb47dc6f579e 

#根据日志创建目录

```

### 重新初始化haproxy（两个节点都执行）**

```shell
cd /data/lb/etc
vi haproxy.cfg 
#加入另外节点信息
 server rancher01 192.168.160.10:6443
  server rancher01 192.168.160.11:6443
  
docker ps -a
#删除haproxy并重新初始化
docker rm -f HAProxy-K8S && bash /data/lb/start-haproxy.sh
```

### 部署网络

```shell
##新版本kube flannel方法
wget https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel.yml

kubectl create -f kube-flannel.yml

##k8s-1.15.1方法
访问https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel.yml

打开 kube-flannel-old.yaml 复制里面的内容

回到flannel目录创建kube-flannel.yml并将内容粘贴至改文件后执行：
kubectl create -f kube-flannel.yml 
```

### 将子节点加入到master

### Etcd 集群状态查看

```shell
kubectl -n kube-system exec etcd-k8s-master1 -- etcdctl \
--endpoints=https://192.168.160.10:2379 \
--ca-file=/etc/kubernetes/pki/etcd/ca.crt \
--cert-file=/etc/kubernetes/pki/etcd/server.crt \
--key-file=/etc/kubernetes/pki/etcd/server.key cluster-health

kubectl get endpoints kube-controller-manager --namespace=kube-system -o yaml

kubectl get endpoints kube-scheduler --namespace=kube-system -o yaml
```

# 资源清单

## 常用字段说明

```yaml
#简单的yaml文件
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  namespace: default
  labels:
    app: myapp
    version: v1
spec:
  containers:
  - name: app
    image: tomcat_test:v3
```

```shell
#运行
[root@k8s-master1 ~]# kubectl apply -f pod.yaml
[root@k8s-master1 ~]# kubectl get pod -o wide
NAME          READY   STATUS    RESTARTS   AGE     IP           NODE        NOMINATED NODE   READINESS GATES
myapp-pod     2/2     Running   0          5m36s   10.244.3.4   k8s-node2   <none>           <none>
```

##  init容器

### init实例1

```yaml
# vi init-pod.yaml

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2;done;']
  - name: init-mydb
    image: busybox
    command: ['sh', '-c', 'until nslookup mydb; do echo waiting for mydb; sleep 2; done;']
```

```shell
kubectl create -f init-pod.yaml
kubectl get pod -o wide   #发现pod创建不成功
kubectl describe pod myapp-pod #发现只有myapp-container容器创建成功
kubectl log  myapp-pod -c init-myservice #查看该容器创建失败
```

```yaml
#vi myservice.yaml
kind: Service
apiVersion: v1
metadata:
  name: myservice
spec:
  ports:
   - protocol: TCP
    port: 80
    targetPort: 9376
```

```shell
kubectl get svc
```

```yaml
#vi mydb
kind: Service
apiVersion: v1
metadata:
  name: mydb
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9377
```

```shell
kubectl get svc
kubectl get pod -o wide #发现pod已经启动成功
```

## 探针

### 就绪检测-readinessProbe-httpget

实例

```yaml
# vi readinessProbe-httpget.yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-httpget-pod
  namespace: default
spec:
  containers:
  - name: readiness-httpget-container
    image: tomcat_test:v4
    imagePullPolicy: IfNotPresent
    readinessProbe:
      httpGet:
        port: 8080
        path: /index1.html
      initialDelaySeconds: 1
      periodSeconds: 3
```

```shell
kubectl create -f readinessProbe-httpget.yaml
kubectl get pod # 发现没有ready，原因是不存在/index1.html
#将上面的path: /index1.html 修改为 /test/index.jsp后重新创建pod则成功ready
```

### 存活检测-livenessProbe-exec

```yaml
#vi livenessProbe-exec
apiVersion: v1
kind: Pod
metadata:
  name: liveness-exec-pod
  namespace: default
spec:
  containers:
  - name: liveness-exec-container
    image: busybox
    imagePullPolicy: IfNotPresent
    command: ["/bin/sh","-c","touch /tmp/live ; sleep 60; rm -rf /tmp/live; sleep 3600"]
    livenessProbe:
      exec:
        command: ["test","-e","/tmp/live"]
      initialDelaySeconds: 1
      periodSeconds: 3
```

### 存活检测-livenessProbe-httpget

```yaml
#vi livenessProbe-httpget.yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-httpget-pod
  namespace: default
spec:
  containers:
  - name: liveness-httpget-container
    image: tomcat_test:v3
    imagePullPolicy: IfNotPresent
    ports:
    - name: tomcat
      containerPort: 8080
    livenessProbe:
      httpGet:
        port: 8080
        path: /test/index.jsp
      initialDelaySeconds: 1
      periodSeconds: 3
      timeoutSeconds: 10
```

```shell
#检测该pod正常存货。进入容器删除项目文件再观察
kubectl exec liveness-httpget-pod -c liveness-httpget-container -it /bin/sh  #进入容器
#进入容器后删除/test/index.jsp，退出后发现pod重启
```

### 存活检测-livenessProbe-tcp

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-tcp
spec:
  containers:
  - name: tomcat
    image: tomcat_test:v3
    livenessProbe:
      initialDelaySeconds: 5
      timeoutSeconds: 1
      tcpSocket:
        port: 8080
```

### 合并使用

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-httpget-pod
  namespace: default
spec:
  containers:
  - name: liveness-httpget-container
    image: tomcat_test:v3
    imagePullPolicy: IfNotPresent
    ports:
    - name: tomcat
      containerPort: 8080
    readinessProbe:
      httpGet:
        port: 8080
        path: /test/index.jsp
      initialDelaySeconds: 1
      periodSeconds: 3
    livenessProbe:
      httpGet:
        port: 8080
        path: /test/index.jsp
      initialDelaySeconds: 1
      periodSeconds: 3
      timeoutSeconds: 10
```

### 启动、退出动作

```yml
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-demo
spec:
  containers:
  - name: lifecycle-demo-container
    image: nginx
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"]
      preStop:
        exec:
          command: ["/bin/sh", "-c", "echo Hello from the poststop handler > /usr/share/message"]
```

## 资源控制器

### RS 与 RC 与 Deployment 关联

RC （ReplicationController ）主要的作用就是用来确保容器应用的副本数始终保持在用户定义的副本数 。即如
果有容器异常退出，会自动创建新的Pod来替代；而如果异常多出来的容器也会自动回收
Kubernetes 官方建议使用 RS（ReplicaSet ） 替代 RC （ReplicationController ） 进行部署，RS 跟 RC 没有
本质的不同，只是名字不一样，并且 RS 支持集合式的 selector

```yaml
apiVersion: extensions/v1beta1
kind: ReplicaSet
metadata:
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: tomcat-test
        image: tomcat_test:v3
        env:
        - name: GET_HOSTS_FROM
          value: dns
        ports:
        - containerPort: 8080
```

### Deployment

Deployment 为 Pod 和 ReplicaSet 提供了一个声明式定义(declarative)方法，用来替代以前的
ReplicationController 来方便的管理应用。典型的应用场景包括：
定义Deployment来创建Pod和ReplicaSet
滚动升级和回滚应用
扩容和缩容
暂停和继续Deployment

#### Ⅰ、部署一个简单的 tomcat 应用

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: tomcat-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: tomcat-test
    spec:
      containers:
      - name: tomcat-test
        image: tomcat_test:v3
        ports:
        - containerPort: 8080
```

#### Deployment 更新策略

Deployment 可以保证在升级时只有一定数量的 Pod 是 down 的。默认的，它会确保至少有比期望的Pod数量少
一个是up状态（最多一个不可用）
Deployment 同时也可以确保只创建出超过期望数量的一定数量的 Pod。默认的，它会确保最多比期望的Pod数
量多一个的 Pod 是 up 的（最多1个 surge ）
未来的 Kuberentes 版本中，将从1-1变成25%-25%

#### Rollover（多个rollout并行）

假如您创建了一个有5个niginx:1.7.9 replica的 Deployment，但是当还只有3个nginx:1.7.9 的 replica 创建
出来的时候您就开始更新含有5个nginx:1.9.1 replica 的 Deployment。在这种情况下，Deployment 会立即
杀掉已创建的3个nginx:1.7.9 的 Pod，并开始创建nginx:1.9.1 的 Pod。它不会等到所有的5个nginx:1.7.9 的
Pod 都创建完成后才开始改变航道

#### 清理 Policy

您可以通过设置.spec.revisonHistoryLimit 项来指定 deployment 最多保留多少 revision 历史记录。默认的会
保留所有的 revision；如果将该项设置为0，Deployment 就不允许回退了

### DaemonSet

DaemonSet 确保全部（或者一些）Node 上运行一个 Pod 的副本。当有 Node 加入集群时，也会为他们新增一
个 Pod 。当有 Node 从集群移除时，这些 Pod 也会被回收。删除 DaemonSet 将会删除它创建的所有 Pod
使用 DaemonSet 的一些典型用法：
运行集群存储 daemon，例如在每个 Node 上运行 glusterd 、ceph
在每个 Node 上运行日志收集 daemon，例如fluentd 、logstash
在每个 Node 上运行监控 daemon，例如 Prometheus Node Exporter、collectd 、Datadog 代理、
New Relic 代理，或 Ganglia gmond

```yaml
apiVersion: apps/v3
kind: DaemonSet
metadata:
  name: deamonset-example
  labels:
    app: daemonset
spec:
  selector:
    matchLabels:
      name: deamonset-example
  template:
    metadata:
      labels:
        name: deamonset-example
  spec:
    containers:
    - name: daemonset-example
      image: tomcat_test:v3
```

### Job

Job 负责批处理任务，即仅执行一次的任务，它保证批处理任务的一个或多个 Pod 成功结束
特殊说明
spec.template格式同Pod
RestartPolicy仅支持Never或OnFailure
单个Pod时，默认Pod成功运行后Job即结束
.spec.completions 标志Job结束需要成功运行的Pod个数，默认为1
.spec.parallelism 标志并行运行的Pod的个数，默认为1
spec.activeDeadlineSeconds 标志失败Pod的重试最大时间，超过这个时间不会继续重试

```yml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    metadata:
      name: pi
    spec:
      containers:
      - name: pi
        image: perl:v1
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
```

### CronJob Spec

spec.template格式同Pod
RestartPolicy仅支持Never或OnFailure
单个Pod时，默认Pod成功运行后Job即结束
.spec.completions 标志Job结束需要成功运行的Pod个数，默认为1
.spec.parallelism 标志并行运行的Pod的个数，默认为1
spec.activeDeadlineSeconds 标志失败Pod的重试最大时间，超过这个时间不会继续重试

### CronJob

Cron Job 管理基于时间的 Job，即：
在给定时间点只运行一次
周期性地在给定时间点运行
使用条件：当前使用的 Kubernetes 集群，版本 >= 1.8（对 CronJob）
典型的用法如下所示：
在给定的时间点调度 Job 运行
创建周期性运行的 Job，例如：数据库备份、发送邮件

#### CronJob Spec

.spec.schedule ：调度，必需字段，指定任务运行周期，格式同 Cron
.spec.jobTemplate ：Job 模板，必需字段，指定需要运行的任务，格式同 Job
.spec.startingDeadlineSeconds ：启动 Job 的期限（秒级别），该字段是可选的。如果因为任何原因而错
过了被调度的时间，那么错过执行时间的 Job 将被认为是失败的。如果没有指定，则没有期限
.spec.concurrencyPolicy ：并发策略，该字段也是可选的。它指定了如何处理被 Cron Job 创建的 Job 的
并发执行。只允许指定下面策略中的一种：
Allow （默认）：允许并发运行 Job
Forbid ：禁止并发运行，如果前一个还没有完成，则直接跳过下一个
Replace ：取消当前正在运行的 Job，用一个新的来替换
注意，当前策略只能应用于同一个 Cron Job 创建的 Job。如果存在多个 Cron Job，它们创建的 Job 之间总
是允许并发运行。
.spec.suspend ：挂起，该字段也是可选的。如果设置为 true ，后续所有执行都会被挂起。它对已经开始
执行的 Job 不起作用。默认值为 false 。
.spec.successfulJobsHistoryLimit 和 .spec.failedJobsHistoryLimit ：历史限制，是可选的字段。它
们指定了可以保留多少完成和失败的 Job。默认情况下，它们分别设置为 3 和 1 。设置限制的值为 0 ，相
关类型的 Job 完成后将不会被保留。

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```

```yaml
$ kubectl get cronjob
NAME SCHEDULE SUSPEND ACTIVE LAST-SCHEDULE
hello */1 * * * * False 0 <none>
$ kubectl get jobs
NAME DESIRED SUCCESSFUL AGE
hello-1202039034 1 1 49s
$ pods=$(kubectl get pods --selector=job-name=hello-1202039034 --output=jsonpath=
{.items..metadata.name})
$ kubectl logs $pods
Mon Aug 29 21:34:09 UTC 2016
Hello from the Kubernetes cluster
# 注意，删除 cronjob 的时候不会自动删除 job，这些 job 可以用 kubectl delete job 来删除
$ kubectl delete cronjob hello
cronjob "hello" deleted
```

#### CrondJob 本身的一些限制

创建 Job 操作应该是 幂等的

### 命令小结

```shell
kubectl get pod --show-labels #查看pod标签
kubectl label pod frontend-9rskm tier=frontend1 --overwrite=ture #更改pod标签（更改后该pod便不属于之前的rs）
kubectl apply -f deployment.yaml #创建deployment时使用声明式命令apply创建
kubectl apply -f deployment.yaml --record ## --record参数可以记录命令，我们可以很方便的查看每次 revision 的变化
kubectl scale deployment tomcat-deployment --replicas 5 #扩容
kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80 #如果集群支持 horizontal pod autoscaling 的话，还可以为Deployment设置自动扩展
kubectl set image deployment/tomcat-deployment tomcat-test=tomcat-test:v4 #更新镜像版本为v4
kubectl rollout undo deployment/tomcat-deployment #回滚到上一个版本
kubectl describe deployments #查看deployment详细信息

kubectl rollout status deployments tomcat-deployment #查看回滚状态
kubectl rollout history deployment/tomcat-deployment #查看回滚历史信息，创建yaml时加上--record才会显示详细信息
kubectl rollout undo deployment/tomcat-deployment --to-revision=1 ## 可以使用 --revision参数指定
某个历史版本
kubectl rollout pause deployment/tomcat-deployment ## 暂停 deployment 的更新

kubectl get jobs #查看jobs
kubectl get cronjob #查看cronjob
```

# service

## Service 的概念

Kubernetes Service 定义了这样一种抽象：一个 Pod 的逻辑分组，一种可以访问它们的策略 —— 通常称为微
服务。 这一组 Pod 能够被 Service 访问到，通常是通过 Label Selector
Service能够提供负载均衡的能力，但是在使用上有以下限制：
只提供 4 层负载均衡能力，而没有 7 层功能，但有时我们可能需要更多的匹配规则来转发请求，这点上 4 层
负载均衡是不支持的

## Service 的类型

Service 在 K8s 中有以下四种类型
ClusterIp：默认类型，自动分配一个仅 Cluster 内部可以访问的虚拟 IP
NodePort：在 ClusterIP 基础上为 Service 在每台机器上绑定一个端口，这样就可以通过 : NodePort 来访
问该服务
LoadBalancer：在 NodePort 的基础上，借助 cloud provider 创建一个外部负载均衡器，并将请求转发
到: NodePort
ExternalName：把集群外部的服务引入到集群内部来，在集群内部直接使用。没有任何类型代理被创建，
这只有 kubernetes 1.7 或更高版本的 kube-dns 才支持

## VIP 和 Service 代理

在 Kubernetes 集群中，每个 Node 运行一个 kube-proxy 进程。kube-proxy 负责为 Service 实现了一种
VIP（虚拟 IP）的形式，而不是 ExternalName 的形式。 在 Kubernetes v1.0 版本，代理完全在 userspace。在
Kubernetes v1.1 版本，新增了 iptables 代理，但并不是默认的运行模式。 从 Kubernetes v1.2 起，默认就是
iptables 代理。 在 Kubernetes v1.8.0-beta.0 中，添加了 ipvs 代理
在 Kubernetes 1.14 版本开始默认使用 ipvs 代理
在 Kubernetes v1.0 版本， Service 是 “4层”（TCP/UDP over IP）概念。 在 Kubernetes v1.1 版本，新增了
Ingress API（beta 版），用来表示 “7层”（HTTP）服务
！为何不使用 round-robin DNS？

## 代理模式的分类

### Ⅰ、userspace 代理模式

### Ⅱ、iptables 代理模式

### Ⅲ、ipvs 代理模式

这种模式，kube-proxy 会监视 Kubernetes Service 对象和 Endpoints ，调用 netlink 接口以相应地创建
ipvs 规则并定期与 Kubernetes Service 对象和 Endpoints 对象同步 ipvs 规则，以确保 ipvs 状态与期望一
致。访问服务时，流量将被重定向到其中一个后端 Pod
与 iptables 类似，ipvs 于 netfilter 的 hook 功能，但使用哈希表作为底层数据结构并在内核空间中工作。这意
味着 ipvs 可以更快地重定向流量，并且在同步代理规则时具有更好的性能。此外，ipvs 为负载均衡算法提供了更
多选项，例如：
rr ：轮询调度
lc ：最小连接数
dh ：目标哈希
sh ：源哈希
sed ：最短期望延迟
nq ： 不排队调度

## ClusterIP

clusterIP 主要在每个 node 节点使用 iptables，将发向 clusterIP 对应端口的数据，转发到 kube-proxy 中。然
后 kube-proxy 自己内部实现有负载均衡的方法，并可以查询到这个 service 下对应 pod 的地址和端口，进而把
数据转发给对应的 pod 的地址和端口
为了实现图上的功能，主要需要以下几个组件的协同工作：
apiserver 用户通过kubectl命令向apiserver发送创建service的命令，apiserver接收到请求后将数据存储
到etcd中
kube-proxy kubernetes的每个节点中都有一个叫做kube-porxy的进程，这个进程负责感知service，pod
的变化，并将变化的信息写入本地的iptables规则中
iptables 使用NAT等技术将virtualIP的流量转至endpoint中

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tomcat-deploy
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: tomcat-test
      release: stabel
  template:
    metadata:
      labels:
        app: tomcat-test
        release: stabel
        env: test
    spec:
      containers:
      - name: tomcat-test
        image: tomcat_test:v3
        imagePullPolicy: IfNotPresent
        ports:
        - name: tomcat
          containerPort: 8080
```

创建 Service 信息

```yaml
apiVersion: v1
kind: Service
metadata:
  name: tomcat-test
  namespace: default
spec:
  type: ClusterIP
  selector:
    app: tomcat-test
    release: stabel
  ports:
  - name: tomcat
    port: 8080
    targetPort: 11111
```

## Headless Service

有时不需要或不想要负载均衡，以及单独的 Service IP 。遇到这种情况，可以通过指定 Cluster
IP(spec.clusterIP) 的值为 “None” 来创建 Headless Service 。这类 Service 并不会分配 Cluster IP， kubeproxy
不会处理它们，而且平台也不会为它们进行负载均衡和路由

```yaml
apiVersion: v1
kind: Service
metadata:
  name: tomcat-test-headless
  namespace: default
spec:
  selector:
    app: tomcat-test
    clusterIP: "None"
  ports:
  - port: 8080
    targetPort: 11112


[root@k8s-master mainfests]# dig -t A myapp-headless.default.svc.cluster.local. @10.96.0.10
```

## NodePort

nodePort 的原理在于在 node 上开了一个端口，将向该端口的流量导入到 kube-proxy，然后由 kube-proxy 进
一步到给对应的 pod

```yaml
apiVersion: v1
kind: Service
metadata:
  name: tomcat-test
  namespace: default
spec:
  type: NodePort
  selector:
    app: tomcat-test
    release: stabel
  ports:
  - name: tomcat
    port: 8080
    targetPort: 11113
```

## ExternalName

这种类型的 Service 通过返回 CNAME 和它的值，可以将服务映射到 externalName 字段的内容( 例如：
hub.atguigu.com )。ExternalName Service 是 Service 的特例，它没有 selector，也没有定义任何的端口和
Endpoint。相反的，对于运行在集群外部的服务，它通过返回该外部服务的别名这种方式来提供服务

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service-1
  namespace: default
spec:
  type: ExternalName
  externalName: hub.atguigu.com
```

当查询主机 my-service.defalut.svc.cluster.local ( SVC_NAME.NAMESPACE.svc.cluster.local )时，集群的
DNS 服务将返回一个值 my.database.example.com 的 CNAME 记录。访问这个服务的工作方式和其他的相
同，唯一不同的是重定向发生在 DNS 层，而且不会进行代理或转发

##  ingress

### 各节点下载ingress-nginx所需镜像

```shell
docker pull registry.cn-qingdao.aliyuncs.com/kubernetes_xingej/defaultbackend-amd64:1.5
docker pull registry.cn-qingdao.aliyuncs.com/kubernetes_xingej/nginx-ingress-controller:0.20.0
```

### 运行mandatory.yaml和service-nodeport.yaml文件

#### mandatory.yam

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: default-http-backend
  labels:
    app.kubernetes.io/name: default-http-backend
    app.kubernetes.io/part-of: ingress-nginx
  namespace: ingress-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: default-http-backend
      app.kubernetes.io/part-of: ingress-nginx
  template:
    metadata:
      labels:
        app.kubernetes.io/name: default-http-backend
        app.kubernetes.io/part-of: ingress-nginx
    spec:
      terminationGracePeriodSeconds: 60
      containers:
        - name: default-http-backend
          # Any image is permissible as long as:
          # 1. It serves a 404 page at /
          # 2. It serves 200 on a /healthz endpoint
          image: registry.cn-qingdao.aliyuncs.com/kubernetes_xingej/defaultbackend-amd64:1.5
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 30
            timeoutSeconds: 5
          ports:
            - containerPort: 8080
          resources:
            limits:
              cpu: 10m
              memory: 20Mi
            requests:
              cpu: 10m
              memory: 20Mi

---
apiVersion: v1
kind: Service
metadata:
  name: default-http-backend
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: default-http-backend
    app.kubernetes.io/part-of: ingress-nginx
spec:
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app.kubernetes.io/name: default-http-backend
    app.kubernetes.io/part-of: ingress-nginx

---

kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx

---

kind: ConfigMap
apiVersion: v1
metadata:
  name: tcp-services
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx

---

kind: ConfigMap
apiVersion: v1
metadata:
  name: udp-services
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx

---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx-ingress-serviceaccount
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: nginx-ingress-clusterrole
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
      - endpoints
      - nodes
      - pods
      - secrets
    verbs:
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - nodes
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - services
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - "extensions"
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - events
    verbs:
      - create
      - patch
  - apiGroups:
      - "extensions"
    resources:
      - ingresses/status
    verbs:
      - update

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: nginx-ingress-role
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
      - pods
      - secrets
      - namespaces
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - configmaps
    resourceNames:
      # Defaults to "<election-id>-<ingress-class>"
      # Here: "<ingress-controller-leader>-<nginx>"
      # This has to be adapted if you change either parameter
      # when launching the nginx-ingress-controller.
      - "ingress-controller-leader-nginx"
    verbs:
      - get
      - update
  - apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - create
  - apiGroups:
      - ""
    resources:
      - endpoints
    verbs:
      - get

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: nginx-ingress-role-nisa-binding
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: nginx-ingress-role
subjects:
  - kind: ServiceAccount
    name: nginx-ingress-serviceaccount
    namespace: ingress-nginx

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: nginx-ingress-clusterrole-nisa-binding
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: nginx-ingress-clusterrole
subjects:
  - kind: ServiceAccount
    name: nginx-ingress-serviceaccount
    namespace: ingress-nginx

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ingress-controller
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
      app.kubernetes.io/part-of: ingress-nginx
  template:
    metadata:
      labels:
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/part-of: ingress-nginx
      annotations:
        prometheus.io/port: "10254"
        prometheus.io/scrape: "true"
    spec:
      serviceAccountName: nginx-ingress-serviceaccount
      hostNetwork: true
      containers:
        - name: nginx-ingress-controller
          image: registry.cn-qingdao.aliyuncs.com/kubernetes_xingej/nginx-ingress-controller:0.20.0
          args:
            - /nginx-ingress-controller
            - --default-backend-service=$(POD_NAMESPACE)/default-http-backend
            - --configmap=$(POD_NAMESPACE)/nginx-configuration
            - --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
            - --udp-services-configmap=$(POD_NAMESPACE)/udp-services
            - --publish-service=$(POD_NAMESPACE)/ingress-nginx
            - --annotations-prefix=nginx.ingress.kubernetes.io
          securityContext:
            capabilities:
              drop:
                - ALL
              add:
                - NET_BIND_SERVICE
            # www-data -> 33
            runAsUser: 33
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          ports:
            - name: http
              containerPort: 80
            - name: https
              containerPort: 443
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1

---
```

#### service-nodeport.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
  type: NodePort
  ports:
    - name: http
      port: 80
      targetPort: 80
      protocol: TCP
      nodePort: 32080  #http
    - name: https
      port: 443
      targetPort: 443
      protocol: TCP
      nodePort: 32443  #https
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
```

应用配置

```shell
kubectl apply -f mandatory.yaml
kubectl apply -f service-nodeport.yaml
```

### Ingress HTTP 代理访问

deployment、Service、Ingress Yaml 文件

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: tomcat01
spec:
  replicas: 2
  template:
    metadata:
      labels:
        name: tomcat01
    spec:
      containers:
        - name: tomcat01
          image: tomcat_test:v3
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: svc-1
spec:
  ports:
    - port: 11111
      targetPort: 8080
      protocol: TCP
  selector:
    name: tomcat01
```

```yaml
#新建ingress绑定上面创建的svc
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress01
spec:
  rules:
    - host: www.tomcat01.com
      http:
        paths:
        - path: /
          backend:
            serviceName: svc-1
            servicePort: 11111
```

### Ingress HTTPS 代理访问

创建证书，以及 cert 存储方式

```shell
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=nginxsvc/O=nginxsvc"
kubectl create secret tls tls-secret --key tls.key --cert tls.crt
```

deployment、Service、Ingress Yaml 文件

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: tomcat02
spec:
  replicas: 2
  template:
    metadata:
      labels:
        name: tomcat02
    spec:
      containers:
        - name: tomcat02
          image: tomcat_test:v3
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: svc-2
spec:
  ports:
    - port: 11112
      targetPort: 8080
      protocol: TCP
  selector:
    name: tomcat02

---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress02
spec:
  tls:
    - hosts:
      - www.tomcat02.com
      secretName: tls-secret
  rules:
    - host: www.tomcat02.com
      http:
        paths:
        - path: /test/
          backend:
            serviceName: svc-2
            servicePort: 11112
```

### Nginx 进行 BasicAuth

```shell
yum -y install httpd
htpasswd -c auth admin
kubectl create secret generic basic-auth --from-file=auth
```

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress03
  annotations:
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - admin'
spec:
  rules:
  - host: www.tomcat03.com
    http:
      paths:
      - path: /
        backend:
          serviceName: svc-1
          servicePort: 11111
```

### Nginx 进行重写

**名称**                                                                                           **描述**                                                                                                                        **值**
nginx.ingress.kubernetes.io/rewritetarget                        必须重定向流量的目标URI                                                                                    串
nginx.ingress.kubernetes.io/sslredirect						     指示位置部分是否仅可访问SSL（当Ingress包含证书时默认为True）		 布尔
nginx.ingress.kubernetes.io/forcessl-redirect				   即使Ingress未启用TLS，也强制重定向到HTTPS											布尔nginx.ingress.kubernetes.io/approot                          		定义Controller必须重定向的应用程序根，如果它在'/'上下文中    				 串
nginx.ingress.kubernetes.io/useregex								指示Ingress上定义的路径是否使用正则表达式											布尔

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx-test
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: http://www.tomcat01.com:32080/test/
spec:
  rules:
  - host: www.tomcat04.com
    http:
      paths:
      - path: /
        backend:
          serviceName: svc-1
          servicePort: 11111
```

# 存储

## configmap

### configMap 描述信息

ConfigMap 功能在 Kubernetes1.2 版本中引入，许多应用程序会从配置文件、命令行参数或环境变量中读取配
置信息。ConfigMap API 给我们提供了向容器中注入配置信息的机制，ConfigMap 可以被用来保存单个属性，也
可以用来保存整个配置文件或者 JSON 二进制大对象

### ConfigMap 的创建

#### Ⅰ、使用目录创建

```shell
$ ls docs/user-guide/configmap/kubectl/
game.properties
ui.properties

$ cat docs/user-guide/configmap/kubectl/game.properties
enemies=aliens
lives=3
enemies.cheat=true
enemies.cheat.level=noGoodRotten
secret.code.passphrase=UUDDLRLRBABAS
secret.code.allowed=true
secret.code.lives=30

$ cat docs/user-guide/configmap/kubectl/ui.properties
color.good=purple
color.bad=yellow
allow.textmode=true
how.nice.to.look=fairlyNice

$ kubectl create configmap game-config --from-file=docs/user-guide/configmap/kubectl
```

—from-file 指定在目录下的所有文件都会被用在 ConfigMap 里面创建一个键值对，键的名字就是文件名，值就
是文件的内容

#### Ⅱ、使用文件创建

只要指定为一个文件就可以从单个文件中创建 ConfigMap

```shell
$ kubectl create configmap game-config-2 --from-file=docs/userguide/
configmap/kubectl/game.properties

$ kubectl get configmaps game-config-2 -o yaml
```

—from-file 这个参数可以使用多次，你可以使用两次分别指定上个实例中的那两个配置文件，效果就跟指定整个
目录是一样的

#### Ⅲ、使用字面值创建

使用文字值创建，利用 —from-literal 参数传递配置信息，该参数可以使用多次，格式如下

```shell
$ kubectl create configmap special-config --from-literal=special.how=very --fromliteral=
special.type=charm

$ kubectl get configmaps special-config -o yaml
```

### Pod 中使用 ConfigMap

#### Ⅰ、使用 ConfigMap 来替代环境变量

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm01
  namespace: default
data:
  name: zp01
  sex: man
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm02
  namespace: default
data:
  num: zp04504
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tomcat01
spec:
  containers:
    - name: tomcat01
      image: tomcat_test:v3
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: NAME_KEY
          valueFrom:
            configMapKeyRef:
              name: cm01
              key: name
        - name: SEX_KEY
          valueFrom:
            configMapKeyRef:
              name: cm01
              key: sex
      envFrom:
        - configMapRef:
            name: cm02
  restartPolicy: Never
```

#### Ⅱ、用 ConfigMap 设置命令行参数

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tomcat02
spec:
  containers:
    - name: tomcat02
      image: tomcat_test:v3
      command: [ "/bin/sh", "-c", "echo $(NAME_KEY) $(SEX_KEY)" ]
      env:
        - name: NAME_KEY
          valueFrom:
            configMapKeyRef:
              name: cm01
              key: name
        - name: SEX_KEY
          valueFrom:
            configMapKeyRef:
              name: cm01
              key: sex
  restartPolicy: Never
```

#### Ⅲ、通过数据卷插件使用ConfigMap

在数据卷里面使用这个 ConfigMap，有不同的选项。最基本的就是将文件填入数据卷，在这个文件中，键就是文
件名，键值就是文件内容

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tomcat03
spec:
  containers:
    - name: tomcat03
    image: tomcat_test:v3
    command: [ "/bin/sh", "-c", "sleep 600s" ]
    volumeMounts:
    - name: vm-test
      mountPath: /etc/config
  volumes:
    - name: vm-test
      configMap:
        name: cm01
  restartPolicy: Never
```

### ConfigMap 的热更新

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: tomcat04
spec:
  replicas: 1
  template:
    metadata:
      labels:
        run: tomcat04
    spec:
      containers:
      - name: tomcat04
        image: tomcat_test:v3
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
      volumes:
        - name: config-volume
          configMap:
            name: cm01
```

```shell
[root@k8s-master1]# kubectl exec `kubectl get pods -l run=tomcat04 -o=name|cut -d "/" -f2` cat /etc/config/name
zp01
```

修改 ConfigMap

```shell
$ kubectl edit configmap cm01
```

修改 name 的值为 zp02 等待大概 10 秒钟时间，再次查看环境变量的值

```shell
[root@k8s-master1]# kubectl exec `kubectl get pods -l run=tomcat04 -o=name|cut -d "/" -f2` cat /etc/config/name
zp02
```

ConfigMap 更新后滚动更新 Pod
更新 ConfigMap 目前并不会触发相关 Pod 的滚动更新，可以通过修改 pod annotations 的方式强制触发滚动更新

```shell
$ kubectl patch deployment my-nginx --patch '{"spec": {"template": {"metadata": {"annotations":
{"version/config": "20190411" }}}}}'
```

这个例子里我们在 .spec.template.metadata.annotations 中添加 version/config ，每次通过修改
version/config 来触发滚动更新

**！！！ 更新 ConfigMap 后：**
**使用该 ConfigMap 挂载的 Env 不会同步更新**
**使用该 ConfigMap 挂载的 Volume 中的数据需要一段时间（实测大概10秒）才能同步更新**

## secert

### Secret 存在意义

Secret 解决了密码、token、密钥等敏感数据的配置问题，而不需要把这些敏感数据暴露到镜像或者 Pod Spec
中。Secret 可以以 Volume 或者环境变量的方式使用

Secret 有三种类型：
Service Account ：用来访问 Kubernetes API，由 Kubernetes 自动创建，并且会自动挂载到 Pod 的
/run/secrets/kubernetes.io/serviceaccount 目录中
Opaque ：base64编码格式的Secret，用来存储密码、密钥等
kubernetes.io/dockerconfigjson ：用来存储私有 docker registry 的认证

### Service Account

Service Account 用来访问 Kubernetes API，由 Kubernetes 自动创建，并且会自动挂载到 Pod的
/run/secrets/kubernetes.io/serviceaccount 目录中

```shell
$ kubectl run nginx --image nginx
deployment "nginx" created
$ kubectl get pods
NAME READY STATUS RESTARTS AGE
nginx-3137573019-md1u2 1/1 Running 0 13s
$ kubectl exec nginx-3137573019-md1u2 ls /run/secrets/kubernetes.io/serviceaccount
ca.crt
namespace
token
```

### Opaque Secret

#### Ⅰ、创建说明

Opaque 类型的数据是一个 map 类型，要求 value 是 base64 编码格式：

```shell
$ echo -n "admin" | base64
YWRtaW4=
$ echo -n "1f2d1e2e67df" | base64
MWYyZDFlMmU2N2Rm
```

secrets.yml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  password: MWYyZDFlMmU2N2Rm
  username: YWRtaW4=
```

#### Ⅱ、使用方式

1、将 Secret 挂载到 Volume 中

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: seret-test
  name: seret-test
spec:
  volumes:
  - name: secrets
    secret:
      secretName: mysecret
  containers:
  - image: hub.atguigu.com/library/myapp:v1
    name: db
    volumeMounts:
    - name: secrets
      mountPath: "
      readOnly: true
```

2、将 Secret 导出到环境变量中

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pod-deployment
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: pod-deployment
    spec:
      containers:
      - name: pod-1
        image: hub.atguigu.com/library/myapp:v1
        ports:
        - containerPort: 80
        env:
        - name: TEST_USER
          valueFrom:
            secretKeyRef:
              name: mysecret
              key: username
        - name: TEST_PASSWORD
          valueFrom:
            secretKeyRef:
            name: mysecret
            key: password
```

### kubernetes.io/dockerconfigjson

使用 Kuberctl 创建 docker registry 认证的 secret

```shell
$ kubectl create secret docker-registry myregistrykey --docker-server=DOCKER_REGISTRY_SERVER --
docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=DOCKER_EMAIL
secret "myregistrykey" created.
```

在创建 Pod 的时候，通过 imagePullSecrets 来引用刚创建的 `myregistrykey`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: foo
spec:
  containers:
    - name: foo
      image: roc/awangyang:v1
  imagePullSecrets:
    - name: myregistrykey
```

## volume

容器磁盘上的文件的生命周期是短暂的，这就使得在容器中运行重要应用时会出现一些问题。首先，当容器崩溃
时，kubelet 会重启它，但是容器中的文件将丢失——容器以干净的状态（镜像最初的状态）重新启动。其次，在
Pod 中同时运行多个容器时，这些容器之间通常需要共享文件。Kubernetes 中的 Volume 抽象就很好的解决了
这些问题

Kubernetes 中的卷有明确的寿命 —— 与封装它的 Pod 相同。所f以，卷的生命比 Pod 中的所有容器都长，当这
个容器重启时数据仍然得以保存。当然，当 Pod 不再存在时，卷也将不复存在。也许更重要的是，Kubernetes
支持多种类型的卷，Pod 可以同时使用任意数量的卷

Kubernetes 支持以下类型的卷：

```shell
#awsElasticBlockStore 
#azureDisk 
#azureFile 
#cephfs 
#csi 
#downwardAPI 
#emptyDir
#fc 
#flocker 
#gcePersistentDisk 
#gitRepo 
#glusterfs 
#hostPath 
#iscsi 
#local 
#nfs
#persistentVolumeClaim 
#projected 
#portworxVolume 
#quobyte 
#rbd 
#scaleIO 
#secret
#storageos 
#vsphereVolume
```

### emptyDir

当 Pod 被分配给节点时，首先创建 emptyDir 卷，并且只要该 Pod 在该节点上运行，该卷就会存在。正如卷的名
字所述，它最初是空的。Pod 中的容器可以读取和写入 emptyDir 卷中的相同文件，尽管该卷可以挂载到每个容
器中的相同或不同路径上。当出于任何原因从节点中删除 Pod 时， emptyDir 中的数据将被永久删除

- **emptyDir 的用法有：**
  **暂存空间，例如用于基于磁盘的合并排序**
  **用作长时间计算崩溃恢复时的检查点**
  **Web服务器容器提供数据时，保存内容管理器容器提取的文件**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tomcat01
spec:
  containers:
  - image: tomcat_test:v3
    name: tomcat01
    volumeMounts:
    - mountPath: /test01
      name: zp
  - image: tomcat_test:v4
    name: tomcat02
    volumeMounts:
    - mountPath: /test02
      name: zp
  volumes:
  - name: zp
    emptyDir: {}
```

### hostPath

**hostPath 卷将主机节点的文件系统中的文件或目录挂载到集群中**

- **hostPath 的用途如下：**
  运行需要访问 Docker 内部的容器；使用 /var/lib/docker 的 hostPath
  在容器中运行 cAdvisor；使用 /dev/cgroups 的 hostPath
  允许 pod 指定给定的 hostPath 是否应该在 pod 运行之前存在，是否应该创建，以及它应该以什么形式存在

**除了所需的 path 属性之外，用户还可以为 hostPath 卷指定 type**

**值**										**行为**
											空字符串（默认）用于向后兼容，这意味着在挂载 hostPath 卷之前不会执行任何检查。

DirectoryOrCreate			如果在给定的路径上没有任何东西存在，那么将根据需要在那里创建一个空目录，权限设置为 0755，与 											Kubelet 具有相同的组和所有权。

Directory 							给定的路径下必须存在目录

FileOrCreate						如果在给定的路径上没有任何东西存在，那么会根据需要创建一个空文件，权限设置为 0644，与 Kubelet 具												有相同的组和所有权。

File										 给定的路径下必须存在文件

Socket 									给定的路径下必须存在 UNIX 套接字

CharDevice 							给定的路径下必须存在字符设备

BlockDevice 							给定的路径下必须存在块设备



**使用这种卷类型是请注意，因为：**
由于每个节点上的文件都不同，具有相同配置（例如从 podTemplate 创建的）的 pod 在不同节点上的行为可能会有所不同

当 Kubernetes 按照计划添加资源感知调度时，将无法考虑 hostPath 使用的资源								

在底层主机上创建的文件或目录只能由 root 写入。您需要在特权容器中以 root 身份运行进程，或修改主机
上的文件权限以便写入 hostPath 卷

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tomcat01
spec:
  containers:
  - image: tomcat_test:v3
    name: tomcat01
    volumeMounts:
    - mountPath: /zptest
      name: zptest
  volumes:
  - name: zptest
    hostPath:
      path: /zptest
      type: DirectoryOrCreate
```

### hostpath扩展

```yaml
#创建副本数为1的deployment,随机再node2上
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: tomcat-deployment
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: tomcat-test
    spec:
      containers:
      - name: tomcat-test
        image: tomcat_test:v3
        ports:
        - containerPort: 8080
        volumeMounts:
        - mountPath: /zptest
          name: zptest
      volumes:
      - name: zptest
        hostPath:
          path: /zptest
          type: DirectoryOrCreate
          #最好定义为检查目录是否存在：type: Directory
```

```shell
#扩展副本为4，两个节点都有pod
kubectl scale deployment tomcat-deployment --replicas 4
```

总结：副本为1时创建的文件在扩展后，另一个节点只创建了zptest的空目录，里面没有数据，所以在扩展时需要先把数据拷贝至新扩展节点。在写yaml文件时最好写成type: Directory，这样在扩展节点时会失败，并可以在日志中发现没有创建目录



## PersistentVolume

### 概念

#### PersistentVolume （PV）

是由管理员设置的存储，它是群集的一部分。就像节点是集群中的资源一样，PV 也是集群中的资源。 PV 是
Volume 之类的卷插件，但具有独立于使用 PV 的 Pod 的生命周期。此 API 对象包含存储实现的细节，即 NFS、
iSCSI 或特定于云供应商的存储系统

#### PersistentVolumeClaim （PVC）

是用户存储的请求。它与 Pod 相似。Pod 消耗节点资源，PVC 消耗 PV 资源。Pod 可以请求特定级别的资源
（CPU 和内存）。声明可以请求特定的大小和访问模式（例如，可以以读/写一次或 只读多次模式挂载）

#### 静态 pv

集群管理员创建一些 PV。它们带有可供群集用户使用的实际存储的细节。它们存在于 Kubernetes API 中，可用
于消费

#### 动态

当管理员创建的静态 PV 都不匹配用户的 PersistentVolumeClaim 时，集群可能会尝试动态地为 PVC 创建卷。此
配置基于 StorageClasses ：PVC 必须请求 [存储类]，并且管理员必须创建并配置该类才能进行动态创建。声明该
类为 "" 可以有效地禁用其动态配置
要启用基于存储级别的动态存储配置，集群管理员需要启用 API server 上的 DefaultStorageClass [准入控制器]
。例如，通过确保 DefaultStorageClass 位于 API server 组件的 --admission-control 标志，使用逗号分隔的
有序值列表中，可以完成此操作

#### 绑定

master 中的控制环路监视新的 PVC，寻找匹配的 PV（如果可能），并将它们绑定在一起。如果为新的 PVC 动态
调配 PV，则该环路将始终将该 PV 绑定到 PVC。否则，用户总会得到他们所请求的存储，但是容量可能超出要求
的数量。一旦 PV 和 PVC 绑定后， PersistentVolumeClaim 绑定是排他性的，不管它们是如何绑定的。 PVC 跟
PV 绑定是一对一的映射

### 持久化卷声明的保护

PVC 保护的目的是确保由 pod 正在使用的 PVC 不会从系统中移除，因为如果被移除的话可能会导致数据丢失
当启用PVC 保护 alpha 功能时，如果用户删除了一个 pod 正在使用的 PVC，则该 PVC 不会被立即删除。PVC 的
删除将被推迟，直到 PVC 不再被任何 pod 使用

### 持久化卷类型

PersistentVolume 类型以插件形式实现。Kubernetes 目前支持以下插件类型：
GCEPersistentDisk AWSElasticBlockStore AzureFile AzureDisk FC (Fibre Channel)
FlexVolume Flocker NFS iSCSI RBD (Ceph Block Device) CephFS
Cinder (OpenStack block storage) Glusterfs VsphereVolume Quobyte Volumes
HostPath VMware Photon Portworx Volumes ScaleIO Volumes StorageOS

#### 持久卷演示代码

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0003
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: slow
  mountOptions:
    - hard
    - nfsvers=4.1
  nfs:
    path: /tmp
    server: 172.17.0.2
```

### PV 访问模式

PersistentVolume 可以以资源提供者支持的任何方式挂载到主机上。如下表所示，供应商具有不同的功能，每个
PV 的访问模式都将被设置为该卷支持的特定模式。例如，NFS 可以支持多个读/写客户端，但特定的 NFS PV 可能
以只读方式导出到服务器上。每个 PV 都有一套自己的用来描述特定功能的访问模式
ReadWriteOnce——该卷可以被单个节点以读/写模式挂载
ReadOnlyMany——该卷可以被多个节点以只读模式挂载
ReadWriteMany——该卷可以被多个节点以读/写模式挂载

在命令行中，访问模式缩写为：
RWO - ReadWriteOnce
ROX - ReadOnlyMany
RWX - ReadWriteMany

![02](E:\Typora\image\02.PNG)

### 回收策略

Retain（保留）——手动回收
Recycle（回收）——基本擦除（ rm -rf /thevolume/* ）
Delete（删除）——关联的存储资产（例如 AWS EBS、GCE PD、Azure Disk 和 OpenStack Cinder 卷）
将被删除
当前，只有 NFS 和 HostPath 支持回收策略。AWS EBS、GCE PD、Azure Disk 和 Cinder 卷支持删除策略

### 状态

卷可以处于以下的某种状态：
Available（可用）——一块空闲资源还没有被任何声明绑定
Bound（已绑定）——卷已经被声明绑定
Released（已释放）——声明被删除，但是资源还未被集群重新声明

Failed（失败）——该卷的自动回收失败
命令行会显示绑定到 PV 的 PVC 的名称

### 持久化演示说明 - NFS

#### Ⅰ、安装 NFS 服务器

```shell
yum install -y nfs-common nfs-utils rpcbind
mkdir /nfsdata{1..4}
chmod 666 /nfsdata{1..4}
chown nfsnobody /nfsdata{1..4}
vi /etc/exports
/nfsdata1 *(rw,no_root_squash,no_all_squash,sync)
/nfsdata2 *(rw,no_root_squash,no_all_squash,sync)
/nfsdata3 *(rw,no_root_squash,no_all_squash,sync)
/nfsdata4 *(rw,no_root_squash,no_all_squash,sync)
systemctl start rpcbind
systemctl start nfs
```

```shell
#每个节点安装nfs客户端
[root@k8s-master1 ~]# yum install -y nfs-common nfs-utils rpcbind
#远程查看nfs服务器
[root@k8s-master1 pv-test]# showmount -e 192.168.160.100
Export list for 192.168.160.100:
/nfsdata4 *
/nfsdata3 *
/nfsdata2 *
/nfsdata1 *
#测试挂载，进行读写测试
[root@k8s-master1 ~]# mount -t nfs 192.168.160.100:/nfsdata1 /root/test/
```

#### Ⅱ、部署 4个PV

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfspv1
spec:
  capacity:
    storage: 4Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: zp1
  nfs:
    path: /nfsdata1
    server: 192.168.160.100
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfspv2
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: zp1
  nfs:
    path: /nfsdata2
    server: 192.168.160.100
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfspv3
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadOnlyMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: zp2
  nfs:
    path: /nfsdata3
    server: 192.168.160.100
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfspv4
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: zp2
  nfs:
    path: /nfsdata4
    server: 192.168.160.100
```

#### Ⅲ、创建服务并使用 PVC

```yaml
apiVersion: v1
kind: Service           #类型svc
metadata:
  name: test-svc
  labels:
    app: test-svc-lab
spec:
  ports:
  - port: 8080
    name: tomcat-svc-port
  clusterIP: None         #无头服务的svc
  selector:
    app: tomcat-test01	   #与下面的matchlables相匹配
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: tomcat-test
spec:
  selector:
    matchLabels:
      app: tomcat-test01	#与上面的selector相匹配
  serviceName: "test-svc"
  replicas: 3
  template:
    metadata:
      labels:
        app: tomcat-test01
    spec:
      containers:
      - name: tomcat01
        image: tomcat_test:v3
        ports:
        - containerPort: 8080
          name: tomcat-port
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "nfs"
      resources:
        requests:
          storage: 1Gi
          
```

### 删除pvc、pv

```shell
#删除pvc顺序
kubectl delete svc test-svc
kubectl delete statefulset --all
kubectl delete pod --all
kubectl delete pvc --all
#编辑nfspv1信息
kebctl edit pv nfspv1
#删除以下信息
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: tomcat-vm-tomcat-test-2
    namespace: default
    resourceVersion: "4926026"
    uid: fa43d8a6-36bb-470e-b8fd-c8c8ee4d6898
#删除以上信息后nfspv1变为Available可用状态
```

检测无头服务域名解析

```shell
dig -t A test-svc(无头服务的svc).default.svc.cluster.local. @10.244.1.2(kube-system下的coredns地址)

#返回以下信息则为解析正常
;; ANSWER SECTION:
test-svc.default.svc.cluster.local. 30 IN A	10.244.3.50
test-svc.default.svc.cluster.local. 30 IN A	10.244.3.49
test-svc.default.svc.cluster.local. 30 IN A	10.244.2.47
```



### 关于 StatefulSet

匹配 Pod name ( 网络标识 ) 的模式为：$(statefulset名称)-$(序号)，比如上面的示例：web-0，web-1，
web-2
StatefulSet 为每个 Pod 副本创建了一个 DNS 域名，这个域名的格式为： $(podname).(headless server
name)，也就意味着服务间是通过Pod域名来通信而非 Pod IP，因为当Pod所在Node发生故障时， Pod 会
被飘移到其它 Node 上，Pod IP 会发生变化，但是 Pod 域名不会有变化
StatefulSet 使用 Headless 服务来控制 Pod 的域名，这个域名的 FQDN 为：$(service
name).$(namespace).svc.cluster.local，其中，“cluster.local” 指的是集群的域名
根据 volumeClaimTemplates，为每个 Pod 创建一个 pvc，pvc 的命名规则匹配模式：
(volumeClaimTemplates.name)-(pod_name)，比如上面的 volumeMounts.name=www， Pod
name=web-[0-2]，因此创建出来的 PVC 是 www-web-0、www-web-1、www-web-2
删除 Pod 不会删除其 pvc，手动删除 pvc 将自动释放 pv

#### Statefulset的启停顺序：

有序部署：部署StatefulSet时，如果有多个Pod副本，它们会被顺序地创建（从0到N-1）并且，在下一个
Pod运行之前所有之前的Pod必须都是Running和Ready状态。
有序删除：当Pod被删除时，它们被终止的顺序是从N-1到0。
有序扩展：当对Pod执行扩展操作时，与部署一样，它前面的Pod必须都处于Running和Ready状态。

#### StatefulSet使用场景：

稳定的持久化存储，即Pod重新调度后还是能访问到相同的持久化数据，基于 PVC 来实现。
稳定的网络标识符，即 Pod 重新调度后其 PodName 和 HostName 不变。
有序部署，有序扩展，基于 init containers 来实现。
有序收缩。

# k8s集群调度

## 调度说明

### 简介

Scheduler 是 kubernetes 的调度器，主要的任务是把定义的 pod 分配到集群的节点上。听起来非常简单，但有
很多要考虑的问题：
**公平：如何保证每个节点都能被分配资源**
**资源高效利用：集群所有资源最大化被使用**
**效率：调度的性能要好，能够尽快地对大批量的 pod 完成调度工作**
**灵活：允许用户根据自己的需求控制调度的逻辑**
Sheduler 是作为单独的程序运行的，启动之后会一直坚挺 API Server，获取 PodSpec.NodeName 为空的 pod，
对每个 pod 都会创建一个 binding，表明该 pod 应该放到哪个节点上

### 调度过程

调度分为几个部分：首先是过滤掉不满足条件的节点，这个过程称为 predicate ；然后对通过的节点按照优先级
排序，这个是 priority ；最后从中选择优先级最高的节点。如果中间任何一步骤有错误，就直接返回错误



Predicate 有一系列的算法可以使用：
**PodFitsResources ：节点上剩余的资源是否大于 pod 请求的资源**
**PodFitsHost ：如果 pod 指定了 NodeName，检查节点名称是否和 NodeName 匹配**
**PodFitsHostPorts ：节点上已经使用的 port 是否和 pod 申请的 port 冲突**
**PodSelectorMatches ：过滤掉和 pod 指定的 label 不匹配的节点**
**NoDiskConflict ：已经 mount 的 volume 和 pod 指定的 volume 不冲突，除非它们都是只读**



如果在 predicate 过程中没有合适的节点，pod 会一直在 pending 状态，不断重试调度，直到有节点满足条件。
经过这个步骤，如果有多个节点满足条件，就继续 priorities 过程： 按照优先级大小对节点排序
优先级由一系列键值对组成，键是该优先级项的名称，值是它的权重（该项的重要性）。这些优先级选项包括：
**LeastRequestedPriority ：通过计算 CPU 和 Memory 的使用率来决定权重，使用率越低权重越高。换句话**
**说，这个优先级指标倾向于资源使用比例更低的节点**
**BalancedResourceAllocation ：节点上 CPU 和 Memory 使用率越接近，权重越高。这个应该和上面的一起**
**使用，不应该单独使用**
**ImageLocalityPriority ：倾向于已经有要使用镜像的节点，镜像总大小值越大，权重越高**
通过算法对所有的优先级项目和权重进行计算，得出最终的结果

### 自定义调度器

除了 kubernetes 自带的调度器，你也可以编写自己的调度器。通过 spec:schedulername 参数指定调度器的名
字，可以为 pod 选择某个调度器进行调度。比如下面的 pod 选择 my-scheduler 进行调度，而不是默认的
default-scheduler ：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: annotation-second-scheduler
  labels:
    name: multischeduler-example
spec:
  schedulername: my-scheduler
  containers:
  - name: pod-with-second-annotation-container
    image: gcr.io/google_containers/pause:2.0
```

## 调度亲和性

### 节点亲和性

#### pod.spec.nodeAffinity

**requiredDuringSchedulingIgnoredDuringExecution：硬策略**

***preferredDuringSchedulingIgnoredDuringExecution：软策略***



#### requiredDuringSchedulingIgnoredDuringExecution

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: tomcat-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: tomcat-test
    spec:
      containers:
      - name: tomcat-test
        image: tomcat_test:v3
        ports:
        - containerPort: 8080
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname    #匹配的键值为主机名，可通过kubectl get node --show-labels查看
                operator: NotIn                #必须不在values值范围内，也就是该pod不在node2上创建
                values:
                - k8s-node2
```

#### preferredDuringSchedulingIgnoredDuringExecution

```yaml

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: tomcat-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: tomcat-test
    spec:
      containers:
      - name: tomcat-test
        image: tomcat_test:v3
        ports:
        - containerPort: 8080
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1                        #因为是软策略，所以需要权重级别
            preference:
              matchExpressions:
              - key: kubernetes.io/hostname  #匹配的键值为主机名，可通过kubectl get node --show-labels查看
                operator: In                 #最好在values值范围内，也可以不在，不是必须的（软策略:有就满足，没有算了）
                values:
                - k8s-node3
```

#### 合体

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity
  labels:
    app: node-affinity-pod
spec:
  containers:
  - name: with-node-affinity
    image: hub.atguigu.com/library/myapp:v1
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: NotIn
            values:
            - k8s-node02
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: source
            operator: In
            values:
            - qikqiak
```

#### 键值运算关系

**In：label 的值在某个列表中**
**NotIn：label 的值不在某个列表中**
**Gt：label 的值大于某个值**
**Lt：label 的值小于某个值**
**Exists：某个 label 存在**
**DoesNotExist：某个 label 不存在**

### Pod 亲和性

#### pod.spec.affinity.podAffinity/podAntiAffinity

**preferredDuringSchedulingIgnoredDuringExecution：软策略**
**requiredDuringSchedulingIgnoredDuringExecution：硬策略**

```yaml
#与带有标签pod-1的pod创建在同一拓扑域
apiVersion: v1
kind: Pod
metadata:
  name: pod-3
  labels:
    app: pod-3
spec:
  containers:
  - name: pod-3
    image: tomcat_test:v3
  affinity:
    podAffinity:                  #与匹配标签的pod在同一拓扑域
      requiredDuringSchedulingIgnoredDuringExecution:    #pod硬策略
      - labelSelector:            #标签选择
          matchExpressions:
          - key: app
            operator: In
            values:
            - pod-1               #匹配标签为pod-1的pod
        topologyKey: kubernetes.io/hostname #指定拓扑域为主机名，那么上方的同一拓扑域就指在同一台主机。拓扑域可自定义修改  

#与带有标签pod-1的pod不创建在同一拓扑域
    podAntiAffinity:				#与匹配标签的pod不在同一拓扑域
      preferredDuringSchedulingIgnoredDuringExecution:		#pod软策略
      - weight: 1
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - pod-1
          topologyKey: kubernetes.io/hostname
```

### 亲和性/反亲和性调度策略比较如下：

![03](E:\Typora\image\03.PNG)



## 污点

### Taint 和 Toleration

节点亲和性，是 pod 的一种属性（偏好或硬性要求），它使 pod 被吸引到一类特定的节点。Taint 则相反，它使
节点 能够 排斥 一类特定的 pod
Taint 和 toleration 相互配合，可以用来避免 pod 被分配到不合适的节点上。每个节点上都可以应用一个或多个
taint ，这表示对于那些不能容忍这些 taint 的 pod，是不会被该节点接受的。如果将 toleration 应用于 pod
上，则表示这些 pod 可以（但不要求）被调度到具有匹配 taint 的节点上

### 污点(Taint)

#### Ⅰ、 污点 ( Taint ) 的组成

使用 kubectl taint 命令可以给某个 Node 节点设置污点，Node 被设置上污点之后就和 Pod 之间存在了一种相
斥的关系，可以让 Node 拒绝 Pod 的调度执行，甚至将 Node 已经存在的 Pod 驱逐出去
每个污点的组成如下：

```shell
key=value:effect
```

每个污点有一个 key 和 value 作为污点的标签，其中 value 可以为空，effect 描述污点的作用。当前 taint
effect 支持如下三个选项：
NoSchedule ：表示 k8s 将不会将 Pod 调度到具有该污点的 Node 上
PreferNoSchedule ：表示 k8s 将尽量避免将 Pod 调度到具有该污点的 Node 上
NoExecute ：表示 k8s 将不会将 Pod 调度到具有该污点的 Node 上，同时会将 Node 上已经存在的 Pod 驱
逐出去

#### Ⅱ、污点的设置、查看和去除

```shell
# 设置污点
kubectl taint nodes k8s-node1 key1=zp:NoExecute
# 节点说明中，查找 Taints 字段
kubectl describe pod pod-name
# 去除污点
kubectl taint nodes k8s-node1 key1=zp:NoExecute-
```

### 容忍(Tolerations)

设置了污点的 Node 将根据 taint 的 effect：NoSchedule、PreferNoSchedule、NoExecute 和 Pod 之间产生
互斥的关系，Pod 将在一定程度上不会被调度到 Node 上。 但我们可以在 Pod 上设置容忍 ( Toleration ) ，意思
是设置了容忍的 Pod 将可以容忍污点的存在，可以被调度到存在污点的 Node 上

pod.spec.tolerations

```yaml
#为pod设置节点污点容忍
apiVersion: v1
kind: Pod
metadata:
  name: pod-1
  labels:
    app: pod-1
spec:
  containers:
  - name: pod-1
    image: tomcat_test:v3
  tolerations:
  - key: key1          #上方节点污点的键名
    operator: "Equal"
    value: zp          #上方节点污点的键值
    effect: "NoExecute"     #同上方污点设置相同
    tolerationSeconds: 3600    #容忍的时间，容忍3600秒后该pod仍会被驱逐
```



```yaml
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
  tolerationSeconds: 3600
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoExecute"
- key: "key2"
  operator: "Exists"
  effect: "NoSchedule"
```

其中 key, vaule, effect 要与 Node 上设置的 taint 保持一致
operator 的值为 Exists 将会忽略 value 值
tolerationSeconds 用于描述当 Pod 需要被驱逐时可以在 Pod 上继续保留运行的时间

#### Ⅰ、当不指定 key 值时，表示容忍所有的污点 key：

```yaml
tolerations:
- operator: "Exists"
```

#### Ⅱ、当不指定 effect 值时，表示容忍所有的污点作用

```yaml
tolerations:
- key: "key"
  operator: "Exists"
```

#### Ⅲ、有多个 Master 存在时，防止资源浪费，可以如下设置

```shell
kubectl taint nodes k8s-master2 node-role.kubernetes.io/master=:PreferNoSchedule
```

## 指定调度节点

Ⅰ、Pod.spec.nodeName 将 Pod 直接调度到指定的 Node 节点上，会跳过 Scheduler 的调度策略，该匹配规则是强制匹配

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: spec1
spec:
  replicas: 7
  template:
    metadata:
      labels:
        app: spec1
    spec:
      nodeName: k8s-node1     #指定node1创建pod，7个pod副本都会创建在node1上
      containers:
      - name: spec1
        image: tomcat_test:v3
        ports:
        - containerPort: 8080
```

Ⅱ、Pod.spec.nodeSelector：通过 kubernetes 的 label-selector 机制选择节点，由调度器调度策略匹配 label，
而后调度 Pod 到目标节点，该匹配规则属于强制约束

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: myweb
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: myweb
    spec:
      nodeSelector:
        type: backEndNode1
      containers:
      - name: myweb
        image: harbor/tomcat:8.5-jre8
        ports:
        - containerPort: 80
```

```shell
kubectl label node k8s-node1 disk=ssd     #给node1打上disk=ssd的标签
```

# 安全

## 机制说明

Kubernetes 作为一个分布式集群的管理工具，保证集群的安全性是其一个重要的任务。API Server 是集群内部
各个组件通信的中介，也是外部控制的入口。所以 Kubernetes 的安全机制基本就是围绕保护 API Server 来设计
的。Kubernetes 使用了认证（Authentication）、鉴权（Authorization）、准入控制（Admission
Control）三步来保证API Server的安全

![04](F:\软件\Typora\image\04.PNG)

## 认证（Authentication）

**HTTP Token 认证：通过一个 Token 来识别合法用户**
HTTP Token 的认证是用一个很长的特殊编码方式的并且难以被模仿的字符串 - Token 来表达客户的一
种方式。Token 是一个很长的很复杂的字符串，每一个 Token 对应一个用户名存储在 API Server 能访
问的文件中。当客户端发起 API 调用请求时，需要在 HTTP Header 里放入 Token

**HTTP Base 认证：通过 用户名+密码 的方式认证**
用户名+：+密码 用 BASE64 算法进行编码后的字符串放在 HTTP Request 中的 Heather
Authorization 域里发送给服务端，服务端收到后进行编码，获取用户名及密码

**最严格的 HTTPS 证书认证：基于 CA 根证书签名的客户端身份认证方式**

### Ⅰ、HTTPS 证书认证：

![05](F:\软件\Typora\image\05.PNG)

### Ⅱ、需要认证的节点

![07](F:\软件\Typora\image\07.PNG)

**两种类型**
Kubenetes 组件对 API Server 的访问：kubectl、Controller Manager、Scheduler、kubelet、kubeproxy
Kubernetes 管理的 Pod 对容器的访问：Pod（dashborad 也是以 Pod 形式运行）

**安全性说明**
Controller Manager、Scheduler 与 API Server 在同一台机器，所以直接使用 API Server 的非安全端口
访问， --insecure-bind-address=127.0.0.1
kubectl、kubelet、kube-proxy 访问 API Server 就都需要证书进行 HTTPS 双向认证

**证书颁发**
手动签发：通过 k8s 集群的跟 ca 进行签发 HTTPS 证书
自动签发：kubelet 首次访问 API Server 时，使用 token 做认证，通过后，Controller Manager 会为
kubelet 生成一个证书，以后的访问都是用证书做认证了

### Ⅲ、kubeconfig

kubeconfig 文件包含集群参数（CA证书、API Server地址），客户端参数（上面生成的证书和私钥），集群
context 信息（集群名称、用户名）。Kubenetes 组件通过启动时指定不同的 kubeconfig 文件可以切换到不同
的集群

### Ⅳ、ServiceAccount

Pod中的容器访问API Server。因为Pod的创建、销毁是动态的，所以要为它手动生成证书就不可行了。
Kubenetes使用了Service Account解决Pod 访问API Server的认证问题

### Ⅴ、Secret 与 SA 的关系

Kubernetes 设计了一种资源对象叫做 Secret，分为两类，一种是用于 ServiceAccount 的 service-accounttoken，
另一种是用于保存用户自定义保密信息的 Opaque。ServiceAccount 中用到包含三个部分：Token、
ca.crt、namespace
`token是使用 API Server 私钥签名的 JWT。用于访问API Server时，Server端认证`
`ca.crt，根证书。用于Client端验证API Server发送的证书`
`namespace, 标识这个service-account-token的作用域名空间`

```shell
kubectl get secret --all-namespaces
kubectl describe secret default-token-5gm9r --namespace=kube-system
```

默认情况下，每个 namespace 都会有一个 ServiceAccount，如果 Pod 在创建时没有指定 ServiceAccount，
就会使用 Pod 所属的 namespace 的 ServiceAccount

### 总结

![08](F:\软件\Typora\image\08.PNG)

## 鉴权（Authorization）

上面认证过程，只是确认通信的双方都确认了对方是可信的，可以相互通信。而鉴权是确定请求方有哪些资源的权
限。API Server 目前支持以下几种授权策略 （通过 API Server 的启动参数 “--authorization-mode” 设置）
**AlwaysDeny：表示拒绝所有的请求，一般用于测试**
**AlwaysAllow：允许接收所有请求，如果集群不需要授权流程，则可以采用该策略**
**ABAC（Attribute-Based Access Control）：基于属性的访问控制，表示使用用户配置的授权规则对用户请求进行匹配和控制**
**Webbook：通过调用外部 REST 服务对用户进行授权**
**RBAC（Role-Based Access Control）：基于角色的访问控制，现行默认规则**

#### RBAC 授权模式

RBAC（Role-Based Access Control）基于角色的访问控制，在 Kubernetes 1.5 中引入，现行版本成为默认标
准。相对其它访问控制方式，拥有以下优势：

- 对集群中的资源和非资源均拥有完整的覆盖

- 整个 RBAC 完全由几个 API 对象完成，同其它 API 对象一样，可以用 kubectl 或 API 进行操作

- 可以在运行时进行调整，无需重启 API Server

Ⅰ、RBAC 的 API 资源对象说明
RBAC 引入了 4 个新的顶级资源对象：Role、ClusterRole、RoleBinding、ClusterRoleBinding，4 种对象类型
均可以通过 kubectl 与 API 操作

![09](F:\软件\Typora\image\09.PNG)

需要注意的是 Kubenetes 并不会提供用户管理，那么 User、Group、ServiceAccount 指定的用户又是从哪里
来的呢？ Kubenetes 组件（kubectl、kube-proxy）或是其他自定义的用户在向 CA 申请证书时，需要提供一个
证书请求文件

```yml
  {
    "CN": "admin",
    "hosts": [],
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "ST": "HangZhou",
        "L": "XS",
        "O": "system:masters",
        "OU": "System"
      }
    ]
  }
```

API Server会把客户端证书的CN 字段作为User，把names.O 字段作为Group
kubelet 使用 TLS Bootstaping 认证时，API Server 可以使用 Bootstrap Tokens 或者 Token authentication
file 验证 =token，无论哪一种，Kubenetes 都会为 token 绑定一个默认的 User 和 Group
Pod使用 ServiceAccount 认证时，service-account-token 中的 JWT 会保存 User 信息
有了用户信息，再创建一对角色/角色绑定(集群角色/集群角色绑定)资源对象，就可以完成权限绑定了

#### Role and ClusterRole

在 RBAC API 中，Role 表示一组规则权限，权限只会增加(累加权限)，不存在一个资源一开始就有很多权限而通过
RBAC 对其进行减少的操作；Role 可以定义在一个 namespace 中，如果想要跨 namespace 则可以创建
ClusterRole

```yml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

ClusterRole 具有与 Role 相同的权限角色控制能力，不同的是 ClusterRole 是集群级别的，ClusterRole 可以用
于:

- 集群级别的资源控制( 例如 node 访问权限 )

- 非资源型 endpoints( 例如 /healthz 访问 )

- 所有命名空间资源控制(例如 pods )

```yml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

#### RoleBinding and ClusterRoleBinding

RoloBinding 可以将角色中定义的权限授予用户或用户组，RoleBinding 包含一组权限列表(subjects)，权限列
表中包含有不同形式的待授予权限资源类型(users, groups, or service accounts)；RoloBinding 同样包含对被
Bind 的 Role 引用；RoleBinding 适用于某个命名空间内授权，而 ClusterRoleBinding 适用于集群范围内的授
权
将 default 命名空间的 pod-reader Role 授予 jane 用户，此后 jane 用户在 default 命名空间中将具有 podreader
的权限

```yml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

RoleBinding 同样可以引用 ClusterRole 来对当前 namespace 内用户、用户组或 ServiceAccount 进行授权，
这种操作允许集群管理员在整个集群内定义一些通用的 ClusterRole，然后在不同的 namespace 中使用
RoleBinding 来引用
例如，以下 RoleBinding 引用了一个 ClusterRole，这个 ClusterRole 具有整个集群内对 secrets 的访问权限；
但是其授权用户 dave 只2能访问 development 空间中的 secrets(因为 RoleBinding 定义在 development 命
名空间)

```yml
# This role binding allows "dave" to read secrets in the "development" namespace.
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: read-secrets
  namespace: development # This only grants permissions within the "development" namespace.
subjects:
- kind: User
  name: dave
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

使用 ClusterRoleBinding 可以对整个集群中的所有命名空间资源权限进行授权；以下 ClusterRoleBinding 样例
展示了授权 manager 组内所有用户在全部命名空间中对 secrets 进行访问

```yml
# This cluster role binding allows anyone in the "manager" group to read secrets in any
namespace.
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: read-secrets-global
subjects:
- kind: Group
  name: manager
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

#### Resources

Kubernetes 集群内一些资源一般以其名称字符串来表示，这些字符串一般会在 API 的 URL 地址中出现；同时某些
资源也会包含子资源，例如 logs 资源就属于 pods 的子资源，API 中 URL 样例如下

```shell
GET /api/v1/namespaces/{namespace}/pods/{name}/log
```

如果要在 RBAC 授权模型中控制这些子资源的访问权限，可以通过 / 分隔符来实现，以下是一个定义 pods 资资源
logs 访问权限的 Role 定义样例

```yml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: pod-and-pod-logs-reader
rules:
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list"]
```

#### to Subjects

RoleBinding 和 ClusterRoleBinding 可以将 Role 绑定到 Subjects；Subjects 可以是 groups、users 或者
service accounts
Subjects 中 Users 使用字符串表示，它可以是一个普通的名字字符串，如 “alice”；也可以是 email 格式的邮箱
地址，如 “wangyanglinux@163.com”；甚至是一组字符串形式的数字 ID 。但是 Users 的前缀 system: 是系统
保留的，集群管理员应该确保普通用户不会使用这个前缀格式
Groups 书写格式与 Users 相同，都为一个字符串，并且没有特定的格式要求；同样 system: 前缀为系统保留

#### 实践：创建一个用户只能管理 dev 空间

```shell
{
  "CN": "devuser",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}

# 下载证书生成工具
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
mv cfssl_linux-amd64 /usr/local/bin/cfssl
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
cfssl gencert -ca=ca.crt -ca-key=ca.key -profile=kubernetes /root/devuser-csr.json | cfssljson
-bare devuser
# 设置集群参数
export KUBE_APISERVER="https://172.20.0.113:6443"
kubectl config set-cluster kubernetes \
--certificate-authority=/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=devuser.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials devuser \
--client-certificate=/etc/kubernetes/ssl/devuser.pem \
--client-key=/etc/kubernetes/ssl/devuser-key.pem \
--embed-certs=true \
--kubeconfig=devuser.kubeconfig
# 设置上下文参数
kubectl config set-context kubernetes \
--cluster=kubernetes \
--user=devuser \
--namespace=dev \
--kubeconfig=devuser.kubeconfig
# 设置默认上下文
kubectl config use-context kubernetes --kubeconfig=devuser.kubeconfig
cp -f ./devuser.kubeconfig /root/.kube/config
kubectl create rolebinding devuser-admin-binding --clusterrole=admin --user=devuser --
namespace=dev
```

## 准入控制

准入控制是API Server的插件集合，通过添加不同的插件，实现额外的准入控制规则。甚至于API Server的一些主
要的功能都需要通过 Admission Controllers 实现，比如 ServiceAccount
官方文档上有一份针对不同版本的准入控制器推荐列表，其中最新的 1.14 的推荐列表是：

```txt
NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,Mutat
ingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota
```

列举几个插件的功能：

- NamespaceLifecycle： 防止在不存在的 namespace 上创建对象，防止删除系统预置 namespace，删除

- namespace 时，连带删除它的所有资源对象。

- LimitRanger：确保请求的资源不会超过资源所在 Namespace 的 LimitRange 的限制。

- ServiceAccount： 实现了自动化添加 ServiceAccount。

- ResourceQuota：确保请求的资源不会超过资源的 ResourceQuota 限制。

# helm

## 什么是 Helm

在没使用 helm 之前，向 kubernetes 部署应用，我们要依次部署 deployment、svc 等，步骤较繁琐。况且随
着很多项目微服务化，复杂的应用在容器中部署以及管理显得较为复杂，helm 通过打包的方式，支持发布的版本
管理和控制，很大程度上简化了 Kubernetes 应用的部署和管理

Helm 本质就是让 K8s 的应用管理（Deployment,Service 等 ) 可配置，能动态生成。通过动态生成 K8s 资源清
单文件（deployment.yaml，service.yaml）。然后调用 Kubectl 自动执行 K8s 资源部署

Helm 是官方提供的类似于 YUM 的包管理器，是部署环境的流程封装。Helm 有两个重要的概念：chart 和
release

- chart 是创建一个应用的信息集合，包括各种 Kubernetes 对象的配置模板、参数定义、依赖关系、文档说
  明等。chart 是应用部署的自包含逻辑单元。可以将 chart 想象成 apt、yum 中的软件安装包

- release 是 chart 的运行实例，代表了一个正在运行的应用。当 chart 被安装到 Kubernetes 集群，就生成
  一个 release。chart 能够多次安装到同一个集群，每次安装都是一个 release



Helm 包含两个组件：Helm 客户端和 Tiller 服务器，如下图所示

![10](F:\软件\Typora\image\10.PNG)

## Helm 部署

越来越多的公司和团队开始使用 Helm 这个 Kubernetes 的包管理器，我们也将使用 Helm 安装 Kubernetes 的常用
组件。 Helm 由客户端命 helm 令行工具和服务端 tiller 组成，Helm 的安装十分简单。 下载 helm 命令行工具到
master 节点 node1 的 /usr/local/bin 下，这里下载的 2.13. 1版本：

```shell
ntpdate ntp1.aliyun.com
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.13.1-linux-amd64.tar.gz
tar -zxvf helm-v2.13.1-linux-amd64.tar.gz
cd linux-amd64/
cp helm /usr/local/bin/
chmod +x /usr/local/bin/helm
```

为了安装服务端 tiller，还需要在这台机器上配置好 kubectl 工具和 kubeconfig 文件，确保 kubectl 工具可以
在这台机器上访问 apiserver 且正常使用。 这里的 node1 节点以及配置好了 kubectl

因为 Kubernetes APIServer 开启了 RBAC 访问控制，所以需要创建 tiller 使用的 service account: tiller 并分
配合适的角色给它。 详细内容可以查看helm文档中的 Role-based Access Control。 这里简单起见直接分配
cluster- admin 这个集群内置的 ClusterRole 给它。创建 rbac-config.yaml 文件：

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
```

```shell
kubectl create -f rbac-config.yaml
  serviceaccount/tiller created
  clusterrolebinding.rbac.authorization.k8s.io/tiller created
```

```shell
helm init --service-account tiller --skip-refresh
kubectl get pod -n kube-system -o wide   #发现下载镜像失败
kubectl edit pod tiller-deploy-58565b5464-bvkst  -n kube-system  #修改镜像源为  sapcc/tiller:v2.16.7
kubectl get pod -n kube-system -o wide   #再次查看pod部署成功
```

tiller 默认被部署在 k8s 集群中的 kube-system 这个
namespace 下

```shell
kubectl get pod -n kube-system -l app=helm
NAME READY STATUS RESTARTS AGE
tiller-deploy-c4fd4cd68-dwkhv 1/1 Running 0 83s
helm version
Client: &version.Version{SemVer:"v2.13.1", GitCommit:"618447cbf203d147601b4b9bd7f8c37a5d39fbb4",
GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.13.1", GitCommit:"618447cbf203d147601b4b9bd7f8c37a5d39fbb4",
GitTreeState:"clean"}
```

## Helm 自定义模板

```shell
# 创建文件夹
$ mkdir ./hello-world
$ cd ./hello-world
```

```shell
# 创建自描述文件 Chart.yaml , 这个文件必须有 name 和 version 定义
$ cat <<'EOF' > ./Chart.yaml
name: hello-world
version: 1.0.0
EOF
```

```shell
# 创建模板文件， 用于生成 Kubernetes 资源清单（manifests）
$ mkdir ./templates
$ cat <<'EOF' > ./templates/deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: hello-world
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
        - name: hello-world
          image: tomcat_test:v3
          ports:
            - containerPort: 8080
              protocol: TCP
EOF

$ cat <<'EOF' > ./templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-world
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 8080
    protocol: TCP
  selector:
    app: hello-world
EOF
```

```shell
# 使用命令 helm install RELATIVE_PATH_TO_CHART 创建一次Release
$ helm install .

$ helm list
NAME                  	REVISION	UPDATED                 	STATUS  	CHART            	APP VERSION	NAMESPACE
cantankerous-dachshund	1       	Thu Mar 25 21:56:59 2021	DEPLOYED	hello-world-1.0.0	           	default 

$ helm status cantankerous-dachshund
LAST DEPLOYED: Thu Mar 25 21:56:59 2021
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Pod(related)
NAME                          READY  STATUS   RESTARTS  AGE
hello-world-745d568f5f-glkxm  1/1    Running  0         2m31s

==> v1/Service
NAME         TYPE      CLUSTER-IP     EXTERNAL-IP  PORT(S)         AGE
hello-world  NodePort  10.97.254.159  <none>       8080:30158/TCP  2m32s

==> v1beta1/Deployment
NAME         READY  UP-TO-DATE  AVAILABLE  AGE
hello-world  1/1    1           1          2m31s
```

```shell
# 列出已经部署的 Release
$ helm ls
# 查询一个特定的 Release 的状态
$ helm status RELEASE_NAME
# 移除所有与这个 Release 相关的 Kubernetes 资源
$ helm delete cautious-shrimp
# helm rollback RELEASE_NAME REVISION_NUMBER
$ helm rollback cautious-shrimp 1
# 使用 helm delete --purge RELEASE_NAME 移除所有与指定 Release 相关的 Kubernetes 资源和所有这个
Release 的记录
$ helm delete --purge cautious-shrimp
$ helm ls --deleted
```

```shell
# 配置体现在配置文件 values.yaml
$ cat <<'EOF' > ./values.yaml
image:
  repository: tomcat_test
  tag: 'v3'
EOF


mkdir templates

# 这个文件中定义的值，在模板文件中可以通过 .VAlues对象访问到
$ cat <<'EOF' > ./templates/deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: hello-world
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
        - name: hello-world
          image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
          ports:
            - containerPort: 8080
              protocol: TCP
EOF

# 在 values.yaml 中的值可以被部署 release 时用到的参数 --values YAML_FILE_PATH 或 --set
key1=value1, key2=value2 覆盖掉
$ helm install --set image.tag='latest' .
# 升级版本
helm upgrade -f values.yaml test .

#所需文件和目录结构
[root@k8s-master1 values]# tree
.
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   └── service.yaml
└── values.yaml

#指定版本后，pod自动更新为v4
 helm upgrade cantankerous-dachshund --set image.tag='v4' .
```

## 删除还原

```shell
#临时删除至回收站（可回滚）
$ helm delete cantankerous-dachshund

#列出回收站信息
$ helm list --deleted
NAME                  	REVISION	UPDATED                 	STATUS 	CHART            	APP VERSION	NAMESPACE
cantankerous-dachshund	5       	Thu Mar 25 22:56:33 2021	DELETED	hello-world-1.0.0	           	default  

#回滚至固定版本  helm rollback 名称+版本号
$ helm rollback cantankerous-dachshund 5

#彻底删除
$ helm delete --purge cantankerous-dachshund
```

## Debug

```shell
# 使用模板动态生成K8s资源清单，非常需要能提前预览生成的结果。
# 使用--dry-run --debug 选项来打印出生成的清单文件内容，而不执行部署
helm install . --dry-run --debug --set image.tag=latest
```

## 使用Helm部署 dashboar

更新helm repo源为阿里云

```shell
helm repo remove stable
helm repo add stable https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
helm repo update
helm search stable/kubernetes-dashboard
```

在node查找可用的dashboard镜像

```shell
#后面标注ok的为可用
$ docker search kubernetes-dashboard-amd64
NAME                                                DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
mirrorgooglecontainers/kubernetes-dashboard-amd64                                                   20                   
siriuszg/kubernetes-dashboard-amd64                 gcr.io/google_containers/kubernetes-dashboar…   14                   [OK]
kubernetesdashboarddev/kubernetes-dashboard-amd64                                                   14                   
ist0ne/kubernetes-dashboard-amd64                   https://gcr.io/google_containers/kubernetes-…   12                   [OK]
k8scn/kubernetes-dashboard-amd64                    kubernetes-dashboard-amd64 image                10                   [OK]
```

kubernetes-dashboard.yaml：

```yaml
image:
  repository: siriuszg/kubernetes-dashboard-amd64        #修改镜像为可用镜像
  tag: v1.10.1
ingress:
  enabled: true
  hosts:
    - k8s.frognew.com
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
  tls:
    - secretName: frognew-com-tls-secret
      hosts:
      - k8s.frognew.com
rbac:
  clusterAdminRole: true
```

```shell
#安装
helm install stable/kubernetes-dashboard \
-n kubernetes-dashboard \
--namespace kube-system \
-f kubernetes-dashboard.yaml
```

修改为NodePort模式访问

```shell
kubectl edit svc kubernetes-dashboard -n kube-system
```



```shell
$ kubectl -n kube-system get secret | grep kubernetes-dashboard-token

kubernetes-dashboard-token-hk9d7 

$ kubectl describe -n kube-system secret kubernetes-dashboard-token-hk9d7

Name: kubernetes-dashboard-token-pkm2s
Namespace: kube-system Labels: <none> Annotations: kubernetes.io/service-account.name:
kubernetes-dashboard kubernetes.io/service-account.uid: 2f0781dd-156a-11e9-b0f0-080027bb7c43
Type: kubernetes.io/service-account-token Data ==== ca.crt: 1025 bytes namespace: 11 bytes
token:
eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5
pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQ
vc2VjcmV0Lm5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZC10b2tlbi1wa20ycyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWF
jY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2Vydml
jZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjJmMDc4MWRkLTE1NmEtMTFlOS1iMGYwLTA4MDAyN2JiN2M0MyIsInN
1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTprdWJlcm5ldGVzLWRhc2hib2FyZCJ9.24ad6ZgZMxdydp
wlmYAiMxZ9VSIN7dDR7Q6-RLW0qC81ajXoQKHAyrEGpIonfld3gqbE0xO8nisskpmlkQra72-
9X6sBPoByqIKyTsO83BQlME2sfOJemWD0HqzwSCjvSQa0xbUlq9HgH2vEXzpFuSS6Svi7RbfzLXlEuggNoC4MfA4E2hF1OX_
ml8iAKx-49y1BQQe5FGWyCyBSi1TD_-
ZpVs44H5gIvsGK2kcvi0JT4oHXtWjjQBKLIWL7xxyRCSE4HmUZT2StIHnOwlX7IEIB0oBX4mPg2_xNGnqwcu-
8OERU9IoqAAE2cZa0v3b5O2LMcJPrcxrVOukvRIumA
```

```shell
kubectl edit svc kubernetes-dashboard -n kube-system
修改 ClusterIP 为 NodePort
```

## 使用Helm部署metrics-server

从 Heapster 的 github <https://github.com/kubernetes/heapster >中可以看到已经，heapster 已经DEPRECATED。
这里是 heapster的deprecation timeline。 可以看出 heapster 从 Kubernetes 1.12 开始将从 Kubernetes 各种安装脚
本中移除。Kubernetes 推荐使用 metrics-server。我们这里也使用helm来部署metrics-server。



metrics-server.yaml:

```yaml
args:
- --logtostderr
- --kubelet-insecure-tls
- --kubelet-preferred-address-types=InternalIP
```

```shell
helm install stable/metrics-server \
-n metrics-server \
--namespace kube-system \
-f metrics-server.yaml
```

使用下面的命令可以获取到关于集群节点基本的指标信息：

```shell
kubectl top node
NAME   CPU(cores)  CPU%  MEMORY(bytes)  MEMORY%
node1  650m        32%   1276Mi         73%
node2  73m         3%    527Mi          30%
```

```shell
kubectl top pod --all-namespaces
NAMESPACE     NAME                                           CPU(cores) MEMORY(bytes)
ingress-nginx nginx-ingress-controller-6f5687c58d-jdxzk      3m         142Mi
ingress-nginx nginx-ingress-controller-6f5687c58d-lxj5q      5m         146Mi
ingress-nginx nginx-ingress-default-backend-6dc6c46dcc-lf882 1m         4Mi
kube-system   coredns-86c58d9df4-k5jkh                       2m         15Mi
kube-system   coredns-86c58d9df4-rw6tt                       3m         23Mi
kube-system   etcd-node1                                     20m        86Mi
kube-system   kube-apiserver-node1                           33m        468Mi
kube-system   kube-controller-manager-node1                  29m        89Mi
kube-system   kube-flannel-ds-amd64-8nr5j                    2m         13Mi
kube-system   kube-flannel-ds-amd64-bmncz                    2m         21Mi
kube-system   kube-proxy-d5gxv                               2m         18Mi
kube-system   kube-proxy-zm29n                               2m         16Mi
kube-system   kube-scheduler-node1                           8m         28Mi
kube-system   kubernetes-dashboard-788c98d699-qd2cx          2m         16Mi
kube-system   metrics-server-68785fbcb4-k4g9v                3m         12Mi
kube-system   tiller-deploy-c4fd4cd68-dwkhv                  1m         24Mi
```

## 部署prometheus

### 相关地址信息

Prometheus github 地址：https://github.com/coreos/kube-prometheus

### 组件说明

1.MetricServer：是kubernetes集群资源使用情况的聚合器，收集数据给kubernetes集群内使用，如
kubectl,hpa,scheduler等。 2.PrometheusOperator：是一个系统监测和警报工具箱，用来存储监控数据。
3.NodeExporter：用于各node的关键度量指标状态数据。 4.KubeStateMetrics：收集kubernetes集群内资源对象数
据，制定告警规则。 5.Prometheus：采用pull方式收集apiserver，scheduler，controller-manager，kubelet组件数
据，通过http协议传输。 6.Grafana：是可视化数据统计和监控平台。

### 构建记录

```shell
git clone https://github.com/coreos/kube-prometheus.git
cd /root/kube-prometheus/manifests
```

修改 grafana-service.yaml 文件，使用 nodepode 方式访问 grafana：

```yaml
vim grafana-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
spec:
  type: NodePort #添加内容
  ports:
  - name: http
    port: 3000
    targetPort: http
    nodePort: 30100 #添加内容
  selector:
    app: grafana
```

修改 prometheus-service.yaml，改为 nodepode

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    prometheus: k8s
  name: prometheus-k8s
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - name: web
    port: 9090
    targetPort: web
    nodePort: 30200
  selector:
    app: prometheus
    prometheus: k8s
```

修改 alertmanager-service.yaml，改为 nodepode

```yaml
vim alertmanager-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    alertmanager: main
  name: alertmanager-main
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - name: web
    port: 9093
    targetPort: web
    nodePort: 30300
  selector:
    alertmanager: main
    app: alertmanager
```

### Horizontal Pod Autoscaling

Horizontal Pod Autoscaling 可以根据 CPU 利用率自动伸缩一个 Replication Controller、Deployment 或者
Replica Set 中的 Pod 数量

```shell
kubectl run php-apache --image=gcr.io/google_containers/hpa-example --requests=cpu=200m --expose
--port=80
```

创建 HPA 控制器 - 相关算法的详情请参阅这篇文档

```shell
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```

增加负载，查看负载节点数目

```shell
$ kubectl run -i --tty load-generator --image=busybox /bin/sh
$ while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done
```

### 资源限制 - Pod

Kubernetes 对资源的限制实际上是通过 cgroup 来控制的，cgroup 是容器的一组用来控制内核如何运行进程的
相关属性集合。针对内存、CPU 和各种设备都有对应的 cgroup

默认情况下，Pod 运行没有 CPU 和内存的限额。 这意味着系统中的任何 Pod 将能够像执行该 Pod 所在的节点一
样，消耗足够多的 CPU 和内存 。一般会针对某些应用的 pod 资源进行资源限制，这个资源限制是通过
resources 的 requests 和 limits 来实现

```yaml
spec:
    containers:
    - image: xxxx
      imagePullPolicy: Always
      name: auth
      ports:
      - containerPort: 8080
        protocol: TCP
      resources:
        limits:
          cpu: "4"
          memory: 2Gi
        requests:
          cpu: 250m
          memory: 250Mi
```

requests 要分分配的资源，limits 为最高请求的资源值。可以简单理解为初始值和最大值

### 资源限制 - 名称空间

#### Ⅰ、计算资源配额

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: spark-cluster
spec:
  hard:
    pods: "20"
    requests.cpu: "20"
    requests.memory: 100Gi
    limits.cpu: "40"
    limits.memory: 200Gi
```

#### Ⅱ、配置对象数量配额限制

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
  namespace: spark-cluster
spec:
  hard:
    configmaps: "10"
    persistentvolumeclaims: "4"
    replicationcontrollers: "20"
    secrets: "10"
    services: "10"
    services.loadbalancers: "2"
```

#### Ⅲ、配置 CPU 和 内存 LimitRange

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 50Gi
      cpu: 5
    defaultRequest:
      memory: 1Gi
      cpu: 1
    type: Container
```

- default 即 limit 的值

- defaultRequest 即 request 的值

### 访问 prometheus

prometheus 对应的 nodeport 端口为 30200，访问 http://MasterIP:30200

![11](F:\软件\Typora\image\11.PNG)

通过访问 http://MasterIP:30200/target 可以看到 prometheus 已经成功连接上了 k8s 的 apiserver

![12](F:\软件\Typora\image\12.PNG)

查看 service-discovery

![13](F:\软件\Typora\image\13.PNG)

Prometheus 自己的指标

![14](F:\软件\Typora\image\14.PNG)

prometheus 的 WEB 界面上提供了基本的查询 K8S 集群中每个 POD 的 CPU 使用情况，查询条件如下：

```yaml
sum by (pod_name)( rate(container_cpu_usage_seconds_total{image!="", pod_name!=""}[1m] ) )
```

![15](F:\软件\Typora\image\15.PNG)

上述的查询有出现数据，说明 node-exporter 往 prometheus 中写入数据正常，接下来我们就可以部署
grafana 组件，实现更友好的 webui 展示数据了

### 访问 grafana

查看 grafana 服务暴露的端口号：

```shell
kubectl get service -n monitoring | grep grafana
  grafana     NodePort     10.107.56.143   <none>     3000:30100/TCP   20h
```

如上可以看到 grafana 的端口号是 30100，浏览器访问 http://MasterIP:30100 用户名密码默认 admin/admin

![17](F:\软件\Typora\image\17.PNG)

修改密码并登陆

![16](F:\软件\Typora\image\16.PNG)

添加数据源 grafana 默认已经添加了 Prometheus 数据源，grafana 支持多种时序数据源，每种数据源都有各自
的查询编辑器

![18](F:\软件\Typora\image\18.PNG)

Prometheus 数据源的相关参数：

![19](F:\软件\Typora\image\19.PNG)

目前官方支持了如下几种数据源：

![20](F:\软件\Typora\image\20.PNG)

## 部署EFK

### 添加 Google incubator 仓库

```SHELL
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm repo add incubator https://kubernetes.oss-cn-hangzhou.aliyuncs.com/kubernetes-charts-incubator
```

### 部署 Elasticsearch

```shell
kubectl create namespace efk
helm fetch incubator/elasticsearch
helm install --name els1 --namespace=efk -f values.yaml incubator/elasticsearch
kubectl run cirror-$RANDOM --rm -it --image=cirros -- /bin/sh
curl Elasticsearch:Port/_cat/nodes
```

### 部署 Fluentd

```shell
helm fetch stable/fluentd-elasticsearch
vim values.yaml
# 更改其中 Elasticsearch 访问地址
helm install --name flu1 --namespace=efk -f values.yaml stable/fluentd-elasticsearch
```

### 部署 kibana

```shell
helm fetch stable/kibana --version 0.14.8
helm install --name kib1 --namespace=efk -f values.yaml stable/kibana --version 0.14.8
```

# 证书有效期修改

## 1、go 环境部署

```SHELL
wget https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
tar -zxvf go1.12.1.linux-amd64.tar.gz -C /usr/local
vi /etc/profile
export PATH=$PATH:/usr/local/go/bin
source /etc/profile
```

## 2、下载源码

```shell
cd /data && git clone https://github.com/kubernetes/kubernetes.git
git checkout -b remotes/origin/release-1.15.1 v1.15.1
```

## 3、修改 Kubeadm 源码包更新证书策略

```shell
vim staging/src/k8s.io/client-go/util/cert/cert.go # kubeadm 1.14 版本之前
vim cmd/kubeadm/app/util/pkiutil/pki_helpers.go # kubeadm 1.14 至今
  const duration365d = time.Hour * 24 * 365
  NotAfter: time.Now().Add(duration365d).UTC(),

make WHAT=cmd/kubeadm GOFLAGS=-v
cp _output/bin/kubeadm /root/kubeadm-new
```

## 4、更新 kubeadm

```shell
# 将 kubeadm 进行替换
cp /usr/bin/kubeadm /usr/bin/kubeadm.old
cp /root/kubeadm-new /usr/bin/kubeadm
chmod a+x /usr/bin/kubeadm
```

## 5、更新各节点证书至 Master 节点

```shell
cp -r /etc/kubernetes/pki /etc/kubernetes/pki.old
cd /etc/kubernetes/pki
kubeadm alpha certs renew all --config=/root/kubeadm-config.yaml
openssl x509 -in apiserver.crt -text -noout | grep Not
```

## 6、HA集群其余 mater 节点证书更新

```shell
#!/bin/bash
masterNode="192.168.66.20 192.168.66.21"
#for host in ${masterNode}; do
# scp /etc/kubernetes/pki/{ca.crt,ca.key,sa.key,sa.pub,front-proxy-ca.crt,front-proxy-ca.key}
"${USER}"@$host:/etc/kubernetes/pki/
# scp /etc/kubernetes/pki/etcd/{ca.crt,ca.key} "root"@$host:/etc/kubernetes/pki/etcd
# scp /etc/kubernetes/admin.conf "root"@$host:/etc/kubernetes/
#done
for host in ${CONTROL_PLANE_IPS}; do

scp /etc/kubernetes/pki/{ca.crt,ca.key,sa.key,sa.pub,front-proxy-ca.crt,front-proxy-ca.key} "${USER}"@$host:/root/pki/

scp /etc/kubernetes/pki/etcd/{ca.crt,ca.key} "root"@$host:/root/etcd

scp /etc/kubernetes/admin.conf "root"@$host:/root/kubernetes/
done
```

