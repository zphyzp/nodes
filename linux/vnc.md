# vnc

```sehll
尽管我们可以使用 SSH连接远程通过字符界面来操作Linux，但是对于更多熟悉图形人来说是很不方便的，因此开启Linux的远程桌面还是很有必要的。目前有两种比较流 行的方式：XDM(X display manager）方案和VNC方案，而我个人比较倾向于VNC方案，一是因为VNC方案配置起来相对比较容易，二是VNC方案支持多种连接方式，比如通过 浏览器访问Linux桌面，免去需要安装客户端的麻烦。

接下来进入具体配置说明：

一， 确认及安装VNCSERVER。

1，首先确认你服务器是否配置了VNCSERVER，可以在命令行下敲入以下命令查看：

[root@localhost: ~]#rpm -qa |grep vnc

vnc-server-4.1.2-14.el5 #返回VNCSEVER服务器端版本说明你已经安装了VNCSERVER。

2，如果没有安装VNCSEVER，那么从光盘找到安装包进行安装。

首先将光盘挂载(也叫解压)到某个目录这里是在/var/ftp/pub/下面建立了rhel5-64目录

mount -o loop rhel-server-5.3-x86_64-dvd.iso /var/ftp/pub/rhel5-64/

然后在/var/ftp/pub/rhel5-64/Server目录下找到 vnc-server-4.1.2-14.el5.x86_64.rpm安装包，使用RPM命令直接安装；

rpm -ivh vnc-server-4.1.2-14.el5.x86_64.rpm


二，开始配置VNCSERVER

1，启动VNCSERVER，第一次启动VNCSERVER会提示输入密码，这里分为管理员账户及普通账户，启动方式略有所不同。

管理员：

[root@localhost /]# vncserver

You will require a password to access your desktops.

Password: 123456 #输入vnc 连接密码

Verify: 123456 #确认vnc密码

xauth: creating new authority file /root/.Xauthority

New ‘localhost.localdomain:1 (root)’ desktop is localhost.localdomain:1

Creating default startup script /root/.vnc/xstartup
Starting applications specified in /root/.vnc/xstartup
Log file is /root/.vnc/localhost.localdomain:1.log


普通用户：

[root@localhost /]#su ceboy #ceboy 是用户名
[ceboy@localhost /]$ vncserver

You will require a password to access your desktops.

Password: 123456 #输入vnc 连接密码

Verify: 123456 #确认vnc密码

xauth: creating new authority file /home/ceboy/.Xauthority

New ‘localhost.localdomain:2 (ceboy)’ desktop is localhost.localdomain:2

Creating default startup script /home/ceboy/.vnc/xstartup
Starting applications specified in /home/ceboy/.vnc/xstartup
Log file is /home/ceboy/.vnc/localhost.localdomain:2.log

# 这里要注意：每个用户都可以启动自己的VNCSERVER远程桌面，同时每个用户可以启动多个VNCSERVER远程桌面，它们用ip加端口 号：ip:1、ip:2、ip:3 来标识、区分，使用同一端口会使另外登录的用户自动退出。另，VNCSERVER的大部分配置文件及日志文件都在用户home目录下.vnc目录下。

用户可以自定义启动号码如：

[ceboy@localhost /]$ vncserver :2 #注意:2前面一定要有空格。
A VNC server is already running as :2

三，相关桌面配置，RedHat Linux支持两种图形模式：KDE模式和gnome模式。

1，你的RH使用的什么图形模式这个一般只有登录到图形界面查看一下才能知道，或者通过ps -A命令列出所有当前运行的程序，看看有没有KDE或者gnome字样来判断一下。

如果你是gnome桌面，那么你需要修改/root/.vnc/xstartup的配置文件。

[root@localhost .vnc]# vi xstartup

#!/bin/sh

# Uncomment the following two lines for normal desktop:

# unset SESSION_MANAGER #将此行的注释去掉

# exec /etc/X11/xinit/xinitrc #将此行的注释去掉

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup

[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources

xsetroot -solid grey

vncconfig -iconic &

xterm -geometry 80×24+10+10 -ls -title “$VNCDESKTOP Desktop” &

gnome-session gnome #添加这一句是连接时使用gnome 桌面环境

twm &

设置修改完毕最好是重启一次系统，否则设置不会生效。我采用的方法是杀死VNCSERVER进程再重运行VNCSERVER。

[root@localhost .vnc]#vncserver -kill :1 #这里你启动vncserver时是什么端口号要对应上。
[root@localhost .vnc]#vncserver :1 #重启VNCSERVER，注意:1前面一定要有空格。

2，设置用户信息及分辨率。

[root@localhost: ~]#vi /etc/sysconfig/vncservers

# The VNCSERVERS variable is a list of display:user pairs.

#

# Uncomment the lines below to start a VNC server on display :2

# as my ‘myusername’ (adjust this to your own). You will also

# need to set a VNC password; run ‘man vncpasswd’ to see how

# to do that.

#

# DO NOT RUN THIS SERVICE if your local area network is

# untrusted! For a secure way of using VNC, see

# <URL:http://www.uk.research.att.com/archive/vnc/sshvnc.html >.

# Use “-nolisten tcp” to prevent X connections to your VNC server via TCP.

# Use “-nohttpd” to prevent web-based VNC clients connecting.

# Use “-localhost” to prevent remote VNC clients connecting except when

# doing so through a secure tunnel. See the “-via” option in the

# `man vncviewer’ manual page.

VNCSERVERS=”1:root 2:ceboy” #此处添加用户，一般只添加一个1:root也就行了。

VNCSERVERARGS[1]=”-geometry 800×600 -nolisten tcp -nohttpd -localhost”
VNCSERVERARGS[2]=”-geometry 1024×768 -nolisten tcp -nohttpd -localhost”

#注意：上面是分别设置的root和ceboy两个用户的分辨率，注意是用端口号区分的。

另外也可以通过命令行临时修改分辨率及色深，这种方式重启后就会丢失，这里暂时用不到，命令如下：

[root@localhost: ~]#vncserver -geometry 800×600 #设置vncserver的分辨率 

[root@localhost: ~]#vncserver -depth 16 #设置vncserver的色深

到这里VNCSERVER服务器端就配置完成了。

四，客户端连接及使用。

1，访问方式
a、在linux下，运行vncviewer命令即可，服务器地址的写法形如192.168.1.11:1
b、在windows下，运行windows版本的vncviewer即可，用法与linux下相近。
c、用浏览器（平台无关），作为java applet来实现，以形如http://192.168.1.11:5801 的方式来启动 （vnc 端口从5800 开始依次类推，一般会是5800，5900）

以下为一些常识：

2，修改密码

运行vncpasswd即可

3，停止vncserver

#vncserver -kill :1
#vncserver -kill :2

注意到vncserver只能由启动它的用户来关闭，即时是root也不能关闭其它用户开启的vncserver，只能用kill命令暴力杀死进程。

4，稳定性设置

vncserver默认在多个客户机连接同一个vncserver的显示端口时，vncserver端口旧连接，而为新连接服务，可通过-dontdisconnect拒绝新连接请求而保持旧的连接。

5，同一个显示器可以连接多个客户机

#vncserver -alwaysshared

6，重启服务

service vncserver restart

7，让系统启动时自动启动VNCSERVER。

使用VNC连接登录到RedHat Linux图形界面，点击“系统”——“管理”——“服务器设置”——“服务”，在“后台服务”中找到VNCSERVER后勾选它，点击保存即可。
```

