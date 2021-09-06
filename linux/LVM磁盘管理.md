# LVM

```SHELL
1、详解/etc/fstab
[root@Oracle ~]# cat /etc/fstab     #开机自动挂载

/dev/mapper/vg_oracle-lv_root /                       ext4    defaults        1 1
UUID=b14ee6ec-86f7-46ac-8ca6-74640b8702ca /boot                   ext4    defaults        1 2
/dev/mapper/vg_oracle-lv_home /home                   ext4    defaults        1 2
/dev/mapper/vg_oracle-lv_swap swap                    swap    defaults        0 0
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                         sysfs   defaults        0 0
proc                    /proc                       proc    defaults        0 0

#/dev/mapper/vg_oracle-lv_root   那个盘
  /                                               挂载在哪里
ext4                                            文件格式
defaults                                       挂载选项（默认）
1				  检测顺序   （一般系统分区需要检测，自己添加的盘不需要检测，使用0 0 即可）
2                                                检测顺序
UUID=b14ee6ec-86f7-46ac-8ca6-74640b8702ca # UUID 可以使用blkid命令查询UUID   推荐使用这样的方式挂载
```

# 扫描磁盘

```SHELL
cd /sys/class/scsi_host
cd host0
echo "- - -" > scan
```

# lvm扩展磁盘

lvm扩展磁盘

    安装操作系统的时候，做了LVM，应用软件基本装在了“/”目录下，服务器运行一段时间后，该目录下的存储空间使用紧张，现利用LVM对其进行磁盘空间扩容。
注：安装系统的时候需要做逻辑卷管理，保证系统要有VG，扩展或者添加完硬盘后需要重启服务器，添加的硬盘才能被发现。
另：这里需要搞清楚，是扩展了原有分区还是增加了新的硬盘；
例如：如果是在原有分区SDA上扩展了10G，则命令行fdisk -l 不会看到新的分区；
           如果是新添加的硬盘，fdisk -l 可以看到 sdb sdc 等新的未分配的分区。
结果演示：扩展sda，磁盘分区sda使用情况打印输出：（可以看到空间变成了32.2G增大了10G）

![image-20210113091019580](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113091019580.png)

为服务器增加新硬盘，这里我们加了两块，开机识别出来是sdb和sdc；
(1) 我们可以看到有3块硬盘，第一块硬盘已经分区并使用，第二块和第三块硬盘没有使用，现在我们要在第二块硬盘sdb上新建LVM分区

![image-20210113091035512](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113091035512.png)

使用fdisk /dev/sdb进行分区，按n创建一个新的分区，按P创建主分区，按1，创建第一块分区，选择开始磁道，按照默认模式开始，使用整个硬盘空间。创建好后按w生效退出。（注意：即使是另一种情况，扩展sda，也需要对sda重新分区，Partition number (1-4)时输入对应的数值。）

![image-20210113091044736](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113091044736.png)

将新的分区，格式化；
#mkfs -t ext3 /dev/sdb1   （如果找不到刚才的分区sdb1,需要重新启动系统；默认的“done”不用手动敲，等待一会儿会自动出现。）

![image-20210113091206848](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113091206848.png)

(2) 把分区改为LVM格式
修改分区格式，使新建的分区支持LVM格式。进入fdisk后，按t修改分区格式，类型改为8e（之前默认的是83）。按w保存生效。

![image-20210113091254062](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113091254062.png)

执行partprobe ,不用重启机器，使分区表生效。
fdisk -l 查看刚加的分区，格式已经变成LVM 的8e。
3 查看VG
#vgdisplay

![image-20210113091325064](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113091325064.png)

VolGroup00是装操作系统的时候，建的；
注: 如果需要单独的VG，可以新建；（我们这次没有新建）
创建命令如下：
#vgcreate VolGroup01 /dev/sdc1
4 查看 PV
使用如下命令创建：pvcreate /dev/sdb1

![image-20210113091347622](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113091347622.png)

查看已经存在的PV，其中/dev/sda2是我们安装操作系统的时候创建的；
#pvdisplay

![image-20210113091405974](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113091405974.png)

5 查看创建 LV
通过查看的命令，可以看到LV：/dev/VolGroup00/LogVol00 就是我们要进行扩展的目录对应的LV

![image-20210113091521933](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113091521933.png)

6. LVM 扩容

7. 扩容VG
  #vgextend VolGroup00 /dev/sdb1

  ![image-20210113091553445](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113091553445.png)

查看扩展后的 VG  增加了10G

![image-20210113091616879](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113091616879.png)

查看当前磁盘空间使用，可以看到当前“/“目录对应的空间大小为14G，所以接下来，LV扩容的话
参数后边需要加数值：24G，表示扩容到24G。

![image-20210113093007904](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113093007904.png)

扩展 LV
#lvextend -L 24G /dev/VolGroup00/LogVol00

![image-20210113093030094](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113093030094.png)

注意：
如果出现下面提示，则说明最大扩展的空间不足，可以将值调小一点，改成23.8G，即比24G小一点（这里根据自身实际要扩展的大小进行调整）。
[root@localhost ~]# lvextend -L 24G /dev/VolGroup00/LogVol00
  Extending logical volume LogVol00 to 26.00 GB
  Insufficient free space: 321 extents needed, but only 320 available
查看扩展后LV大小：
[root@localhost ~]# lvdisplay
我们接着查看，当前的磁盘使用情况，发现没有变化；

![image-20210113093039088](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113093039088.png)

不要急，执行重设大小；
#resize2fs /dev/VolGroup00/LogVol00

![image-20210113093047079](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113093047079.png)

OK ,到这里我们的扩容就完成了。

![image-20210113093052410](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210113093052410.png)



# 磁盘扩容

3.1 【fdisk -l】 最大分区为/dev/sda3，说明新创建的分区将会是sda4
3.2 输入【fdisk /dev/sda】
3.2.1命令行提示下输入【m】
3.2.2输入命令【n】添加新分区。
3.2.3输入命令【p】创建主分区。
3.2.4输入【回车】，选择默认大小，这样不浪费空间
3.2.5输入【回车】，选择默认的start cylinder。
3.2.6输入【w】，保持修改
3.3 输入【reboot】 重启linux，必须reboot，否则/dev/sda4无法格式化。
3.4 这时在/dev/目录下，才能看到了新的分区比如/dev/sda4
3.5 【mkfs.ext2 /dev/sda4】格式化