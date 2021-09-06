# 基础知识

LUN：Logical Unit Number，也就是逻辑单元号。我们知道ISCSI总线上可挂接的设备数量是有限的，一般为8个或者16个，我们可以用Target ID(也有称为ISCSI ID的)来描述这些设备，设备只要一加入系统，就有一个代号，我们在区别设备的时候,只要说几号几号就可以了

HBA:光纤存储卡，用于服务器与光纤阵列规的连接

三种常见的存储方式：
DAS:直接附加存储
NAS:网络附加存储
SAN:存储区域网络

IO流:数据的输入输出形式

虚拟化：虚拟化，是指通过虚拟化技术将一台计算机虚拟为多台逻辑计算机。在一台计算机上同时运行多个逻辑计算机，每个逻辑计算机可运行不同的操作系统，并且应用程序都可以在相互独立的空间内运行而互不影响，从而显著提高计算机的工作效率。虚拟化使用软件的方法重新定义划分IT资源，可以实现IT资源的动态分配、灵活调度、跨域共享，提高IT资源利用率，使IT资源能够真正成为社会基础设施，服务于各行各业中灵活多变的应用需求。

冗余:指重复配置系统的一些部件，当系统发生故障时，冗余配置的部件介入并承担故障部件的工作，由此减少系统的故障时间。
Redundant，自动备援，即当某一设备发生损坏时，它可以自动作为后备式设备替代该设备。利于扩展，应急处理。

I/O:即输入/输出端口。每个设备都会有一个专用的I/O地址，用来处理自己的输入输出信息。CPU与外部设备、存储器的连接和数据交换都需要通过接口设备来实现，前者被称为I/O接口，而后者则被称为存储器接口。存储器通常在CPU的同步控制下工作，接口电路比较简单;而I/O设备品种繁多，其相应的接口电路也各不相同，因此，习惯上说到接口只是指I/O接口。

多路径:安装多路径软件之前两条路径一块盘，但服务器认两块盘。装完多路软件之后，两条路径一块盘，服务器认一块盘

# 2017-3-16

raid1：
             mklv -y datalv00 -t jfs2 -c 3 -s y datavg 10 hdisk1 hdisk2 hdisk3
             列出镜像关系：lslv -m datalv00

卷组的重新组织:reorgvg：reorgvg datavg datalv00
修改外策略：chlv -e x datalv00：修改外策略
mklvcopy添加镜像 ：mklvcopy -s y datalv00 3 hdisk1 hdisk2 hdisk3
syncvg -l datalv00:同步逻辑卷镜像    批处理：syncvg -v datavg
删除镜像：rmlvcopy
卷组镜像：mirrorvg rootvg hdisk1
rootvg的镜像：1,extendvg rootvg hdisk1
                           2,mirrorvg rootvg hdisk1
                           3,bootlist -m normal hdisk0 hdisk1
                           4,bootlist -ad /dev/hdisk1

物理卷的管理：
lspv：查看物理卷      -l hdisk1：查看哪些逻辑卷使用了物理卷      -p hdisk1：查看该物理卷的分区情况
migratepv -l datalv00 hdisk1 hdisk2    将逻辑卷从hdisk1移动到hdisk2上
migratepv hdisk1 hdisk2 将hidsk1所有的逻辑卷移动到hdisk2上

mirroring pool:
                      并行：同时写，读磁盘相对不忙的
                      串行：按顺序写，读数据时始终读第一个

文件系统的管理：
syncd进程：根据log设备1分钟一次写入硬盘
超级块：类型
            状态：clean dirty 
            大小：数据块   inode   
            freelist：空闲数据块，inode

创建文件系统：
1，先创建逻辑卷，在创建文件系统
2，在没有逻辑卷的情况下创建文件系统


1，smit crfs_j2
crfs -v jfs2 -d（有逻辑卷使用-d） /dev/datalv00 -m /p1 -A yes
mount /dev/datalv00 /p1 或者直接 mount /p1
2，crfs -v jfs2 -g(没有逻辑卷使用-g) datavg -m /p1 -A yes -a size=100

log设备:
           为文件系统指定不同log设备
创建LOG设备：mklv -y loglv01 -t jfs2log datavg 1
                     logform /dev/loglv01

创建时指定log设备：crfs ......... -a logname=/dev/loglv01
更改log设备：chfs -a logname=logname=/dev/loglv01 /p1
lsfs -cq /p1：查看文件系统
扩展(修改)文件系统：chfs -a size=512M /p1          chfs -a size=+100M /p1                             
文件系统删除:umount /p1
                   rmfs /p1(连所在逻辑卷一起删除：慎用！)
查看文件系统使用空间：df -k/-m/-g 文件系统

找出占有空间大的文件：du  -s（不展开目录使用）  -k/m/g 目录
crontab -l ：列出任务调度
defraqfs:取消分片
fsck：对文件系统进行一致性检查     umount         fsck /data

配置空间
 查看系统内存大小：lsattr -E -l sys0 -a realmem
vmstat 1 2 ：查看虚拟内存的大小
lsps -a/-s：查看内存使用率/平均使用率

创建配置空间
smit mkps
mkps -t lv -a -n -s 10 datavg hdisk1
增加/减小配置空间chps -s/-d  2 hd6
删除配置空间：
swapoff /dev/paging
rpms paging00


备份与恢复
卷组的备份：rootvg的备份   普通卷组的备份  
文件系统备份：
 文件/目录备份

rootvg备份：smit mksysb
                   /etc/exclude.root:备份时排除文件的配置文件
                  配分到次太极mksysb -X -V -i -m -e -v /dev/rmt0
                  备份成文件mksysb -X -i -m -e -v /另外一个卷组/rootvg.bk
rootvg的恢复：

image.data:rootvg的结构信息       自动产生          手工产生：mkszfile
                 1,重新产生rootvg 2,克隆rootvg 3，修改rootvg的结构ppsize
boinst.data：无人值守的安装过程的文件 

# 2017-3-15

物理设备：
端口：
逻辑设备：软件接口：驱动程序   分配设备文件  设备号      ls -l /dev  major：主设备号  minor：微设备号
虚拟设备
prtconf:查看设备信息
lscfg -v -l xxxxx :查看写在设备里的厂家信息
lsslot -c：查看插槽使用情况
lsdev：显示设备信息
              预定义（predefined）设备：系统所支持的设备   lsdev -P  ；-H 显示标题    
              定制（customized）设备：实际存在的设备   -C 查看定制设备   ；-H 显示标题
              class功能分类：disk硬盘   cdrom光驱  tape    控制器（各种卡）adapter  if网络接口   -c  指定class
              subclass接口分类：sas  scsi fcs vscsi硬盘接口        -s 指定设备的subclass
              type具体型号：-t 指定设备的型号
              -F：查看设备的父设备
sar 1 1：查看cpu情况
lsattr -EH -l 查看设备属性      mode name：机器型号     realmem：内存大小
               -a 指定具体属性并查看
chdev -l 设备 -a 更改属性：  更改设备属性
修改en1的IP地址，子网，状态：chdev -l en1(设备) -a netaddr=192.168.1.1 -a netmask=255.255.255.0 -a state=up 
rendev（aix7.1）修改设备名称： rendev -l 旧名称 -n 新名称
lsvg - rootvg:查看rootvg下的所有逻辑卷
lsfs：查看所有逻辑卷
smit lvm：smit管理逻辑卷          smit vg：smit卷组管理
smit mkvg：创建卷组
lspv：查看所有物理卷      active：打开
？mkvg -y datavg -s 64 hdisk1 hdisk2:创建卷组
lsvg：查看有什么卷组  lsvg -o：查看打开的卷组   lsvg -p rootvg：查看卷组的物理卷     lsvg rootvg：看卷组详细信息
          lsvg -l rootvg：看卷组下逻辑卷
chvg datavg：扩展LUN时需要改变卷组大小
extenlsmdvg datavg hdisk3:扩展卷组     -f：强制扩展
reducevg data hdisk3：删除物理卷    删除所有物理卷即可删除卷组
varyoffvg：关闭卷组，需要先关闭卷组
varyonvg：
exportvg：把卷组信息从ODM中删除
importvg：把卷组信息从VGDA写入ODM
                导入导出作用：迁移数据，解决VGDA和ODM不一致的故障，修改卷组名称
                流程：查看有什么物理卷——>关闭卷组——>导出卷组——>导入卷组：import -y testvg（可以指定新的卷组名） hdisk1(指定一个物理卷即可，为导入VGDA)
逻辑卷：
           普通逻辑卷：1：1
           raid0：条带化
           raid1：镜像
mklv:创建逻辑卷
inter和intra策略：普通逻辑卷/raid0/raid1
scheduling：raid1

创建逻辑卷：mklv -y testvg00 -t jfs2 testvg 10
                  外策略创建(I/O均衡)：mklv -y testlv01 -t jfs2 -e x testvg 12
                  创建条带化创建逻辑卷：mklv -y testlv00 -t jfs2 -S 32k testvg hdisk1 hdisk2 hdisk3
iostat 1 100:查看I/O使用情况
dd if=/dev/zero of=/dev/rtestlv03  count=700   bs=1m   :查看I/O情况是想逻辑卷中写入数据 
查看逻辑卷：lslv testlv00        lslv -m testv00：查看使用空间是否分散
扩展逻辑卷：只要卷组里有空余的物理分区就可以扩展
                 extendlv testlv01 5：增加5个分区
删除逻辑卷：rmlv testlv01

创建文件系统：
                   crfs -v jfs2 -d /dev/testlv01（指定逻辑卷） -m /p1(mount路径) -A yes（自动mount）
                   然后手动MOUNT一下
删除卷组：1，umount挂载   2，rmfs /P1删除文件系统  3，rmlv testlv00删除逻辑卷 4，删除物理卷reducevg testvg                     hdisk1

设备状态： 
cfgmgr:配置新设备     自动执行也可手动执行
mkdev：配置新设备
rmdev -l 设备 ：删掉设备    -d：彻底删除设备


ODM：object data managment

卷组
文件——>目录——>文件系统——>逻辑卷——>物理卷

物理卷（PV）：硬盘
卷组（VG）：物理卷的集合
物理分区（PP）：
逻辑卷（LV）：使用硬盘的方式，是逻辑分区的集合
逻辑分区（LP）：对应物理分区

VGDA;硬盘上的保留空间，当前卷组的结构信息。VGDA有多数，分布在所有物理卷中，每个物理卷中有至少一个VGDA。
quoram：策略    50%以上VGDA是好的则卷组可以打开，反之打不开

逻辑卷：
    文件系统：JFS/JFS2
    LOG设备:可以让文件系统更加稳定
    BOOT设备
    PAGING：虚拟内存
    DUMP设备：查看宕机原因
    RAW设备：直接读取数据

必须mount的文件系统：/   /usr   /tmp   /var
/etc/filesystrms ：文件系统的配置文件

# 2017-3-14

shell
bash
匹配其中任何一个[abcd],[a-z],[a-zA-Z]，加感叹号为取反[!a-z]
ls ne[stw]

重定向
三种设备：标准输入设备：键盘0    标准输出设备：显示器1     标准错误设备：显示器2
输入重定向：<
输出重定向：>,>>
错误重定向：2>

环境变量：PATH,HOME,SHELL
自定义变量类型

位置变量
echo $a:查看变量值
set：显示所有变量
unset a：删除变量值


进程
ps -f：显示进程
echo $?：显示非零证明命令错误，显示0则命令执行成功

交互进程：在命令后加入&，则命令在后台执行。jobs查看后台正在执行的前台进程。fg后台进程转到前台进行。ctrl+z后台停止   bg后台挂起。kill杀死进程
nohup ls -R &:在后台执行，即使退出登录。

K/B .profile
C    .login
bash .bash_profile
cde .dtprofile

find命令 -type f：列出普通文件 
处理措施：-print     -exec 命令   -ok 命令

sort排序 

硬件虚拟化
DLPAR:动态lpar
微分区：0.1个CPU   调整cpu个数为：0.01

smitty:始终以字符串形式执行
smitty -x：模拟执行
smitty -l -s：将日志文件重定向到自定义的文件中


开机与关机
shutdown -Fr：快速关机并重启动

bootlist -m normal -o：查看启动文件所在

/etc/inittab:开机启动文件

chsysstate -m <ms_name> -r sys -o on

ssh hscroot@<hmc> chsysstate -m <ms_name> -r lpar \ -o on -n <lpar> -f <profile name> -b sms:通过ssh方式登陆到HMC的sms状态

SMS:
       安装操作系统
       修改bootlist
       启动操作系统的维护模式

alog -L：查看日志   alog -t boot -o：查看启动过程日志

SRC
lssrc -a:查看所有服务      lssrc -t nfs  查看服务组    lssrc -s 查看具体服务
startsrc -s/-g named:启动服务/服务组
stopsrc -s/-g
refresh：服务重新读取配置文件（不是所有文件都支持这个服务）

oslevel:查看操作系统版本   -r -s查看版本和补丁集

lslpp -l：查看所有软件    lslpp -l 软件名称      lslpp -f 软件名称：查看该软件有什么文件
lslpp -w 文件名称：查看该文件属于哪个软件

系统打补丁不要直接committed，先到applied观察一段时间

smitty install：软件安装
smit update_all:安装补丁     安装补丁时COMMIT选项选择NO，以防无法回退



# 2017-3-13

命令行编辑
以VI的方式编辑命令行：set -o vi
基础命令：
loguout : ctrl+d
cal 1 2015:显示日历2015年1月
who -Hu:用户活动时间
who am i：当前用户
mail team01:向team发送邮件
write team01/write root pts/1
tty:查看终端名称
wall:广播信息
shutdown关机：广播，等待一分钟，同步内存和硬盘
talk命令：实时通信=talk root pts/1
mesg:屏蔽信息
man -k directory:查看关于目录的MAN帮助
pwd：目前所在的目录
ls -a/l/R/i/d       R:递归显示   i:显示inode编号     ls -l -d /etc;查看/etc目录属性
mkdir -p 嵌套创建 ：mkdir -p  /a/b/c/d
more:翻页查看
pd -e:查看系统进程
lslpp -l:查看所有软件
wc -l：按行计数
符号链接(快捷方式)：ln -s 源文件 符号链接文件
硬链接（别名）：ln 源文件 硬链接文件
find -inum:通过inode编号寻找文件
RBAC:基于特定用户的权限
chmod 权限模式 文件 
           权限模式：用户1所有者（u） 用户组（g） 其他用户（o） 所有用户（a）
           修改方式：+ - =
           权限：rwx   421
           普通文件：r 读  w 修改文件   x 执行
           目录文件：r  能够列出目录下的文件和子目录  w 在目录下创建文件和子目录；能够删除目录下的文件和子目录   x cd进入目录权限 
                          SVTX特殊权限（在目录有W权限时才有意义）：任何用户即使对目录有W权限，但是也只能删除自己的文件： chmod +t  /test
umask创建默认权限:修改配置文件/etc/security/user

文件目录：
普通文件:1,文本文件  2，二进制文件
目录文件：
符号链接文件:快捷方式
设备文件：1，字符设备 2，块设备
识别文件类型：ls -l                              
-普通文件
d目录
l符号连接
c设备文件
b块设备

file命令精确的判断文件类型;file /etc

文件系统：对文件的管理

VI的用法
命令模式——>文本模式:a,i,o(在当前光标行之下输入)O(在当前光标行之上输入)
退出VI:wq,q,q!,w file(另存为)，ZZ（保存退出），w（只保存不推出）
vi -r 文件名：找回之前未保存的编辑内容
快速移动光标：ctrl+f/ctrl+b翻页    1G/G/NG 把光标定位到地1/最后/N行    ：set number/no number显示/不显示行号
                     H,L,M光标定位到当前页的第一行，最后一行，中间行     0/$定位到当前行的首/尾     w：两个词之间移动光标
文本的删除：x/nx删除光标处的一/n个字符；dw/ndw: 删除光标处的一/n个word   d0/d$:删除一行光标前/后  dd/ndd：删除一/n行
                    ：20，40d删除20到40行内容       u:删除最后一次保存的内容
文本的搜索：/字符串：按住n/N按照相同/相反的方向搜索下一个
                  ？/字符串
文本替换：r：替换光标处一个字符
               R：替换光标后所有字符
               cn（数字）w：替换光标后的N个word
复制和粘贴：复制：y——>yw:复制光标处的一个word     nyw：复制光标后的n个word  y0/y$：在一行复制光标前/后内容  yy/nyy：复制光标所在处一/n行
                  粘贴：p
剪切和粘贴:      剪切：x，dd，........      粘贴：p
不退出VI情况下执行系统命令：——>:!
查看逻辑CPU个数：pmcycles -m
查看物理CPU个数：prtconf|grep Processors
确定CPU是几核：逻辑CPU除物理CPU
查看CPU信息：lsattr -E -l proc0
查看内存和CPU:prtconf

# 2017-4-27

本地安装LPAR不可以同时安装操作系统

NIM server
1，远程安装
2，远程恢复
3，远程打补丁
4，远程启动到维护模式

ODM
AIX的数据库（二进制文件，相当于windows的注册表）
odmcreate
domshow
odmdrop
odmadd
odmget
odmdelete


lslpp -l:查看软件 -f name 查看软件包含哪些文件
lslpp -p name.sdk 查看依赖关系

查看系统错误日志
errpt -a 查看系统错误日志
errpt -a -j 指定错误ID好 查看错误日志的具体信息
errpt -c > /dev/console  查看并发的错误日志

逻辑卷
chdev -l hdisk1 -a pv=yes 创建ID号
chdev -l hdisk1 -a pv=clear 清空ID号
（生产环境谨慎使用）

卷组的结构信息

