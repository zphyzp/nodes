# apache配置文件

 [httpd.conf](D:\软件\Typora\data\附件\httpd.conf)  

 [httpd-vhosts.conf](D:\软件\Typora\data\附件\httpd-vhosts.conf) 



# 更新apache版本

tar -zxvf httpd-2.4.41.tar.gz

[root@bjgtjnew soft]# cp -Rf apr-util-1.5.4 httpd-2.4.41/srclib/apr-util
[root@bjgtjnew soft]# cp -Rf pcre-8.36 httpd-2.4.41/srclib/pcre
[root@bjgtjnew soft]# cp -Rf apr-1.5.2 httpd-2.4.41/srclib/apr

[root@bjgtjnew ~]# cd /data/soft/httpd-2.4.41

./configure --prefix=/data/apache-2.4.41 --enable-modsshared=more --enable-deflate --enable-speling --enable-cache --enable-file-cache --enable-disk-cache --enable-mem-cache --enable-rewrite --enable-so --with-included-apr --enable-ssl --with-pcre=/usr/local/pcre --with-apr=/usr/local/apr --with-aprutil=/usr/local/apr-util/

make && make install

cp /data/apache-2.4.39/conf/httpd.conf ./
cp /data/apache-2.4.39/conf/extra/httpd-vhosts.conf ./
cp /data/soft/mod_encoding/mod_encoding.so ./

[root@bjgtjnew ~]# cd /usr/sbin/
[root@bjgtjnew sbin]# apachectl stop
[root@bjgtjnew sbin]# vi apachectl
[root@bjgtjnew sbin]# apachectl start

ln -s apache-2.4.41/ apache