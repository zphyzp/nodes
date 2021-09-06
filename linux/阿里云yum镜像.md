## 1.安装wget

yum install -y wget

## 2.完事前都做备份

mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

## 3.下载阿里云镜像文件

wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

 

## 4.清理缓存

yum clean all

##  5.生成缓存

yum makecache

##  6.更新最新源设置

yum update -y