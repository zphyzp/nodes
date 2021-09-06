# ansible管理windows

## 1、ansible管理机安装pip与pywinrm

```shell
#下载最新版pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
#下载python2.7版pip
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py

#安装pip
python get-pip.py

#安装pywinrm
pip install pywinrm
```

## 2、升级powershell

```shell
# 检查powershell版本
get-host
```

## 3、Windows客户端配置winrm，启用powershell远程管理

```shell
1. 查看powershell执行策略
get-executionpolicy

2. 更改powershell执行策略为remotesigned
set-executionpolicy remotesigned

3. 配置winrm service并启动服务
winrm quickconfig

4. 查看winrm service启动监听状态
winrm enumerate winrm/config/listener

5. 修改winrm配置，启用远程连接认证
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
```

## 4、Windows客户端防火墙配置

```shell
打开防火墙高级配置，选择入站规则，在点击新建规则
填写信任端口5985
```

## 5、Ansible服务端配置和测试管理Windows服务器(服务端操作)

```shell
1. 添加windows客户端连接信息
编辑/etc/ansible/hosts，添加客户端主机信息(ansible服务端的配置)
[windows]
172.16.10.23 ansible_ssh_user="Administrator" ansible_ssh_pass="zteict123" ansible_ssh_port=5985 ansible_connection="winrm" ansible_winrm_server_cert_validation=ignore

2. 测试ping探测windows客户主机是否存活
执行命令
ansible 172.16.10.23 -m win_ping
```

