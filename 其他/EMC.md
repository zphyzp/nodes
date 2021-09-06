# EMC多路径软件安装 for aix

## 1、安装odm库，安装后需要重启服务器

```shell
cd /opt/powerpath/odm/EMC.AIX.5.3.1.0
smitty installp
选择下面两个包：
@ 5.3.1.0  EMC CLARiiON AIX Support Software
@ 5.3.1.0  EMC CLARiiON FCP Support Software 
```

## 2、安装powermt path

```shell
cd /opt/powerpath/pp
smitty installp
选择所有的包
```

## 3、注册多路径

```shell
B6PZ-DB4K-FFAC-Q2RW-MH9V-G4EM
BPPF-HB4M-6FFE-QEBO-M79Q-D4ZF

emcpreg -install 输入y   输入授权码
powermt  set policy=co
powermt save
powermt display dev=all
```

## 4、路径错误处理

```shell
powermt config   
powermt restore   
powermt save   转发消息

BLP9-2B4M-BFQD-QTDQ-MY9A-PRSY 
建委P740使用的emc激活码
BTP9-BB4M-BFQE-QFBZ-MM9A-HF4Y
```

# powerpath命令

重新聚合：powermt config
	   powermt save

查看WWN：powermt display dev=all

## --------查看powerpath的注册码---------

[root@bdceqjh ~]# powermt check_registration

Key B6PZ-DB4K-FFAC-Q2RW-MH9V-G4EM
  Product: PowerPath
  Capabilities: All 

## -------查看powerpath下一个可用的设备名--------

[root@bdceqjh init.d]# emcpadm getfreepseudos

Next free pseudo device name(s) from emcpowera are:

Pseudo Device Name      Major# Minor#
	emcpowera         120      0

## -------更改powerpath的设备名，解决rac的两个节点的设备名不一致的问题---------

emcpadm renamepseudo -s emcpowerb -t emcpowera

  

## -------查看powerpath已使用的设备名--------

[root@bdceqjh ~]# emcpadm getusedpseudos
PowerPath pseudo device names in use:

Pseudo Device Name      Major# Minor#
	emcpowera         120      0
	emcpowerb         120     16
	emcpowerc         120     32 
	

## -------解决powerpath设备已取消映射，但设备名还被占用的问题-------

[root@bdceqjh ~]# powermt remove dev=all
[root@bdceqjh ~]# powermt config
[root@bdceqjh ~]# powermt save
[root@bdceqjh ~]# powermt display dev=all
重启powerpath服务器：
/etc/init.d/PowerPath stop
/etc/init.d/PowerPath start



# 常用命令

## 查看hba卡

cd /sys/class/fc_host

![image-20210113152554870](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113152554870.png)

## 查看wwn号

cd /sys/class/fc_host/host0
cat port_name

![image-20210113152605291](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113152605291.png)

## 扫描新加磁盘

cd /sys/class/scsi_host

![image-20210113152615086](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113152615086.png)

cd host0
echo "- - -" > scan
扫描hba卡对应的每个host目录。

## emc多路径软件使用

聚合多路径（对已聚合的没有影响，系统重启会自动聚合）
powermt config

## 查看映射的盘

powermt display dev=all

## 保存配置

powermt save

## 查看总体路径状态

![image-20210113152632194](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113152632194.png)

Summary：optimal（正常）
          Degrade（有路径损坏，同时dead会有显示）
Q-IOs：io队列
Errors：链路报错（有丢包现象）

## 查看详细路径状态

powermt display dev=all

![image-20210113152644920](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113152644920.png)

Pseudo name：聚合磁盘名
Symmetrix ID=000498700540：存储s/n号
Logical device ID：存储逻辑设备号
FA  1g:00：存储前端口号（光口）【存储有2个控制器分别叫1、2，每2个口为一组分别
           叫f0、f1、e0、e1、h0、h1、g0、g1，每个控制器的2个端口映射给一个hba
           卡】