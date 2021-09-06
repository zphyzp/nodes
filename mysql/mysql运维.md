# 权限管理

## 连接权限

### 为192.166.1.100服务器赋予连接mysql权限

```sql
GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.1.100' IDENTIFIED BY 'Wabjtam@119';  
flush privileges;
```

### mysql 8.0.13为192.166.1.00服务器赋予连接mysql权限

```sql
create user 'root'@'192.168.1.100' IDENTIFIED WITH mysql_native_password BY 'Capinfo@123';
grant all privileges on *.* to 'root'@'192.168.1.100' with grant option
flush privileges;
```

## “用户 + IP”的概念

MySQL中同一个用户名，比如Bob,能否登录，以及用什么密码登录，可以访问什么库等等，都需要加上IP，才可以表示一个完整的用户标识
bob@127.0.0.1 和 bob@loalhost 以及 bob@192.168.1.100 这三个其实是不同的 用户标识

## 用户权限管理

### 系统表权限信息:

a) 用户名和IP是否允许
b) 查看mysql.user表 // 查看全局所有库的权限
c) 查看mysql.db表 // 查看指定库的权限
d) 查看mysql.table_priv表 // 查看指定表的权限
e) 查看mysql.column_priv表 // 查看指定列的权限
tips: mysql> desc [tablename]; 可以查看表的结构信息；

### 常用权限：

SQL语句：SELECT、INSERT、UPDATE、DELETE、INDEX
存储过程：CREATE ROUTINE、ALTER ROUTINE、EXECUTE、TRIGGER
管理权限：SUPER、RELOAD、SHOW DATABASE、SHUTDOWN、
所有权限猛戳这里

### 可选资源:

MAX_QUERIES_PER_HOUR count
MAX_UPDATES_PER_HOUR count
MAX_CONNECTIONS_PER_HOUR count
MAX_USER_CONNECTIONS count
tips:只能精确到小时，对于部分场景不适用，可以考虑中间件方式

### 显示当前用户的权限

#这三个是同一个意思

```sql
mysql> show grants;
mysql> show grants for current_user;
mysql> show grants for current_user();
```

## 基本操作

```sql
mysql> create user 'bob'@'127.0.0.1' identified by '123'; 
    #创建一个认证用户为'bob'@'127.0.0.1',密码是123
mysql> grant all on NWDB.* to 'bob'@'127.0.0.1';
    #授予他NWDB库下面所有表的所有访问权限; *.*表示所有库的所有表

mysql> grant all on NWDB.* to 'alice'@'127.0.0.1' identified by '123';
       #这个grant语句会搜索用户，如果用户不存在，则自动创建用户，
       #如果不带identified by, 则该用户名密码为空

mysql> grant all on *.* to 'tom'@'192.168.10.%' identified by '123' with grant option;
       #表示这个用户'tom'@'127.0.0.1'可以访问所有库的所有表，
       #同时，他还可以给其他用户授予权限(with grant option)，
       #注意如果，*.*改成了某一个指定的非USER库，
       #则tom没法去新建其他用户了，因为User库没有权限了
       #192.168.10.% 表示属于192.168.10.0/24网段的用户可以访问
```

## 撤销权限

revoke 关键字，该关键字只删除用户权限，不删除用户
revoke 语法同grant一致, 从grant ... to 变为revoke ... from

正确的创建用户并赋权的方式

```sql
mysql> create user 'pref'@'127.0.0.1' identified by '123';
Query OK, 0 rows affected (0.00sec)
mysql> grant select on sys.* to 'perf'@'127.0.0.1';
Query OK, 0 rows affected (0.00sec)
```



## 实例

### 查看某一个用户的权限

```sql
mysql> show grants for 'perf'@'127.0.0.1';
+-----------------------------------------------+
| Grants for perf@127.0.0.1                     |
+-----------------------------------------------+
| GRANT USAGE ON *.* TO 'perf'@'127.0.0.1'      | -- USAGE表示用户可以登录
| GRANT SELECT ON `sys`.* TO 'perf'@'127.0.0.1' | -- 对sys库的所有表有select权限
+-----------------------------------------------+
2 rows in set (0.00 sec)
```

### 删除某一个用户

```sql
mysql> drop user 'perf'@'127.0.0.1';
Query OK, 0 rows affected (0.00sec)

mysql> select * from mysql.user where user='perf'\G
select * from mysql.db where user='perf'\G  
注意： 
不建议使用INSERT或者GRANT对元数据表进行修改，来达到修改权限的目的
```

### 模拟角色操作(5.7以下不支持)：

```sql
mysql> create user 'junior_dba'@'127.0.0.1';  -- 相当于定于一个 角色(Role),
                                            -- 但这只是个普通的用户，名字比较有(Role)的感觉
                                            -- 有点类似用户组
Query OK, 0 rows affected (0.00sec)

mysql> create user 'tom'@'127.0.0.1';         -- 用户1
Query OK, 0 rows affected (0.02sec)

mysql> create user 'jim'@'127.0.0.1';         -- 用户2
Query OK, 0 rows affected (0.02sec)

mysql> grant proxy on 'junior_dba'@'127.0.0.1' to 'tom'@'127.0.0.1';  -- 将junior_dba的权限映射(map)到tom
Query OK, 0 rows affected (0.02sec)

mysql> grant proxy on 'junior_dba'@'127.0.0.1' to 'jim'@'127.0.0.1';  -- 然后映射(map)给jim
Query OK, 0 rows affected (0.01sec)

mysql> grant select on *.* to 'junior_dba'@'127.0.0.1';  -- 给junior_dba（模拟的Role）赋予实际权限
Query OK, 0 rows affected (0.01 sec)


mysql> show grants for 'junior_dba'@'127.0.0.1';        -- 查看 junior_dba的权限
+-------------------------------------------------+
| Grants for junior_dba@127.0.0.1                 |
+-------------------------------------------------+
| GRANT SELECT ON *.* TO 'junior_dba'@'127.0.0.1' |
+-------------------------------------------------+
1 row in set (0.00 sec)

mysql> show grants for 'jim'@'127.0.0.1';               -- 查看jim的权限
+--------------------------------------------------------------+
| Grants for jim@127.0.0.1                                     |
+--------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'jim'@'127.0.0.1'                      |
| GRANT PROXY ON 'junior_dba'@'127.0.0.1' TO 'jim'@'127.0.0.1' |
+--------------------------------------------------------------+
2 rows in set (0.00 sec)

mysql> show grants for 'tom'@'127.0.0.1';               -- 查看tom的权限 
+--------------------------------------------------------------+
| Grants for tom@127.0.0.1                                     |
+--------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'tom'@'127.0.0.1'                      |
| GRANT PROXY ON 'junior_dba'@'127.0.0.1' TO 'tom'@'127.0.0.1' |
+--------------------------------------------------------------+
2 rows in set (0.00 sec)

mysql> select * from mysql.proxies_priv;    --  查看 proxies_priv的权限
+-----------+------+--------------+--------------+------------+----------------------+---------------------+
| Host      | User | Proxied_host | Proxied_user | With_grant | Grantor              | Timestamp           |
+-----------+------+--------------+--------------+------------+----------------------+---------------------+
| localhost | root |              |              |          1 | boot@connecting host | 0000-00-00 00:00:00 |
| 127.0.0.1 | tom  | 127.0.0.1    | junior_dba   |          0 | root@localhost       | 0000-00-00 00:00:00 |
| 127.0.0.1 | jim  | 127.0.0.1    | junior_dba   |          0 | root@localhost       | 0000-00-00 00:00:00 |
+-----------+------+--------------+--------------+------------+----------------------+---------------------+
3 rows in set (0.00 sec)
mysql.proxies_priv仅仅是对Role的模拟，和Oracle的角色还是有所不同.官方称呼为Role like

------------企业环境授权------------
常规对web应用程序授权
select,insert,update,delete四个权限即可，若个别软件需要create/drop权限，用完收回
```



# MySQL的连接登录

## 几种登录方式

```sql
方式一 mysql -p
该方法默认使用root用户, 可使用select user();查看当前用户

方式二 mysql -S /tmp/mysql.sock -u root -p 密码A
该方法适用于在安装MySQL主机上进行本地登录

方式三 mysql -h 127.0.0.1 -u root -p 密码B
使用'root'@'127.0.0.1'这个用户登录

方式四 mysql -h localhost -u root -p 密码A
该方式等价与【方式二】，且和【方式三】属于两个不同的“用户”
```

## 免密码登录

```sql
方式一 my.cnf增加[client]标签
[client]   
user="root"
  password="你的密码"

  #单对定义不同的客户端

[mysql] # 这个是给/usr/loca/mysql/bin/mysql 使用的
user=root
password="你的密码"

[mysqladmin] # 这个是给/usr/local/mysql/bin/mysqladmin使用的
user=root
password="你的密码"
每个不同的客户端需要定义不同的标签，使用[client]可以统一

方式二 login-path
shell> mysql_config_editor set -G vm1 -S /tmp/mysql.sock -u root -p
Enter password [输入root的密码]

shell> mysql_config_editor print --all
[vm1]
user=root
password=*****
socket=/tmp/mysql.sock

#login

shell> mysql --login-path=vm1 # 这样登录就不需要密码，且文件二进制存储 ,位置是 ~/.mylogin.cnf
该方式相对安全。如果server被黑了，该二进制文件还是会被破解

方式三 ~/.my.cnf, 自己当前家目录
#Filename: ~/.my.cnf
[client]
user="root"
password="你的密码"
```

## 修改密码

```sql
1、mysqladmin -uroot -p'123' passdword '456' -S /data/3306/mysql.sock
2、update mysql.user SET password=PASSWORD("456") WHERE user='root'
     flush privileges;
3、ALTER USER USER() IDENTIFIED BY 'Capinfo@123';         #修改当前用户密码
flush privileges;
```

## 忘记密码

停止mysql服务
以mysql_safe --skip-grant-tables --user=mysql &方式启动
多实例需要指定配置文件，并且将--skip放在后面
在进入mysql修改密码然后再修改重启



# MySQL 参数介绍和设置

## 参数的分类

全局参数：GLOBAL 
可修改参数
不可修改参数
会话参数：SESSION 
可修改参数
不可修改参数
1: 用户可在线修改非只读参数，只读参数只能预先在配置文件中进行设置，通过重启数据库实例,方可生效。
2: 所有的在线修改过的参数(GLOBAL/SESSION)，在重启后，都会丢失，不会写如my.cnf，无法将修改进行持久化
3: 有些参数，即存在于GLOBAL又存在于SESSION, 比如autocommit (PS：MySQL默认是提交的)

## 查看参数

```sql
mysql> show variables; # 显示当前mysql的所有参数，且无隐藏参数
mysql> show variables like "max_%"; #查以max_开头的变量
```

## 设置参数

```sql
设置全局(GLOBAL)参数
mysql> set global slow_query_log = off; #不加global，会提示错误
                                        #slow_query_log是全局参数

mysql> set slow_query_log = off;  # 下面就报错了，默认是会话参数
ERROR 1229 (HY000): Variable 'slow_query_log' is a GLOBAL variable and should be set with SET GLOBAL

设置会话(SESSION)参数
mysql> set autocommit = 0;  # 当前会话生效

或者

mysql> set session autocommit = 0;  # 当前会话生效
autocommit同样在GLOBAL中, 也有同样的参数
mysql> set global autocommit = 1; #当前实例，全局生效
注意：如果这个时候/etc/init.d/mysqld restart, 则全局的autocommit的值会变成默认值，或者依赖于my.cnf的设置值。
执行的效果如下：
mysql> show variables like "slow%"; # 原值为ON
+---------------------+----------+
| Variable_name       | Value    |
+---------------------+----------+
| slow_launch_time    | 2        |
| slow_query_log      | OFF      |
| slow_query_log_file | slow.log |
+---------------------+----------+
3 rows in set (0.00 sec)

mysql> select @@session.autocommit; # 等价于 slect @@autocomit;
+----------------------+
| @@session.autocommit |
+----------------------+
|                    0 |
+----------------------+
1 row in set (0.00 sec)

mysql> select @@global.autocommit;       
+---------------------+
| @@global.autocommit |
+---------------------+
|                   1 |
+---------------------+
1 row in set (0.00 sec)
```

# 慢查询日志进阶

```sql
1. 相关参数：

slow_query_log
是否开启慢查询日志

slow_query_log_file
慢查询日志文件名, 在my.cnf我们已经定义为slow.log，默认是 机器名-slow.log

long_query_time
制定慢查询阈值, 单位是秒，且当版本 >=5.5.X，支持毫秒。例如0.5即为500ms
大于该值，不包括值本身。例如该值为2，则执行时间正好等于2的SQL语句不会记录

log_queries_not_using_indexes
将没有使用索引的SQL记录到慢查询日志 
如果一开始因为数据少，查表快，耗时的SQL语句没被记录，当数据量大时，该SQL可能会执行很长时间
需要测试阶段就要发现问题，减小上线后出现问题的概率

log_throttle_queries_not_using_indexes
限制每分钟内，在慢查询日志中，去记录没有使用索引的SQL语句的次数；版本需要>=5.6.X 
因为没有使用索引的SQL可能会短时间重复执行，为了避免日志快速增大，限制每分钟的记录次数

min_examined_row_limit
扫描记录少于改值的SQL不记录到慢查询日志 
结合去记录没有使用索引的SQL语句的例子，有可能存在某一个表，数据量维持在百行左右，且没有建立索引。这种表即使不建立索引，查询也很快，扫描记录很小，如果确定有这种表，则可以通过此参数设置，将这个SQL不记录到慢查询日志。

log_slow_admin_statements
记录超时的管理操作SQL到慢查询日志，比如ALTER/ANALYZE TABLE

log_output
慢查询日志的格式，[FILE | TABLE | NONE]，默认是FILE；版本>=5.5
如果设置为TABLE，则记录的到mysql.slow_log

log_slow_slave_statements
在从服务器上开启慢查询日志

log_timestamps
写入时区信息。可根据需求记录UTC时间或者服务器本地系统时间
2. 慢查询日志实践
设置慢查询记录的相关参数
--
-- 终端A
--
-- 注意做实验以前，先把my.cnf中的 slow_query_log = 0, 同时将min_examined_row_limit = 100 进行注释
--
mysql> select version();
+-----------+
| version() |
+-----------+
| 5.7.9-log |
+-----------+
1 row in set (0.01 sec)

mysql> show variables like "slow_query_log"； -- 为了测试，特地在my.cnf中关闭了该选项
+----------------+-------+
| Variable_name  | Value |
+----------------+-------+
| slow_query_log | OFF   |
+----------------+-------+
1 row in set (0.00 sec)

mysql> set global slow_query_log = 1;         -- slow_query_log可以在线打开
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like "slow_query_log";  -- 已经打开
+----------------+-------+
| Variable_name  | Value |
+----------------+-------+
| slow_query_log | ON    |
+----------------+-------+
1 row in set (0.00 sec)

mysql> show variables like "long_query_time";
+-----------------+----------+
| Variable_name   | Value    |
+-----------------+----------+
| long_query_time | 2.000000 |   -- my.cnf 中该值设置为2秒
+-----------------+----------+
1 row in set (0.00 sec)

mysql> show variables like "min_ex%";  -- my.cnf 中已经关闭注释，所以这里为0
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| min_examined_row_limit | 0     |
+------------------------+-------+
1 row in set (0.00 sec)
查看慢查询日志
#
#终端B
#
[root@localhost mysql_data]# tail -f slow.log 
/usr/local/mysql/bin/mysqld, Version: 5.7.9-log (MySQL Community Server (GPL)). started with:
Tcp port: 3306  Unix socket: (null)
Time                 Id Command    Argument  #测试没有任何慢查询日志信息
进行模拟耗时操作
--
-- 终端A
--
mysql> select sleep(4);
+----------+
| sleep(4) |
+----------+
|        0 |
+----------+
1 row in set (4.00 sec)
最终产生慢查询日志
#
#终端B
#
[root@localhost mysql_data]# tail -f slow.log 
/usr/local/mysql/bin/mysqld, Version: 5.7.9-log (MySQL Community Server (GPL)). started with:
Tcp port: 3306  Unix socket: (null)
Time                 Id Command    Argument  #测试没有任何慢查询日志信息
# Time: 2015-11-21T07:18:10.741663+08:00
# User@Host: root[root] @ localhost []  Id:     2
# Query_time: 4.000333  Lock_time: 0.000000 Rows_sent: 1  Rows_examined: 0 
                                                          #这个就是min_examined_row_limit
                                                          #设置的意义。如my.cnf中设置该值为100
                                                          #则这条语句因为Rows_examined < 100,而不会被记录
SET timestamp=1448061490;
select sleep(4);
注意 
如果在终端A中set global min_examined_row_limit = 100;, 然后执行select sleep(5);，会发现该记录仍然被记录到慢查询日志中。原因是因为set global min_examined_row_limit设置的是全局变量，此次会话不生效。
但是我们上面set global slow_query_log = 1；却是在线生效的，这点有所不通
mysqldumpslow
[root@localhost mysql_data]# mysqldumpslow  slow.log

Reading mysql slow query log from slow.log
Count: 2  Time=0.00s (0s)  Lock=0.00s (0s)  Rows=0.0 (0), 0users@0hosts
  Time: N-N-21T07:N:N.N+N:N
  # User@Host: root[root] @ localhost []  Id:     N
  # Query_time: N.N  Lock_time: N.N Rows_sent: N  Rows_examined: N
  SET timestamp=N;
  select sleep(N)

Count: 1  Time=0.00s (0s)  Lock=0.00s (0s)  Rows=0.0 (0), 0users@0hosts
  # Time: N-N-21T07:N:N.N+N:N
  # User@Host: root[root] @ localhost []  Id:     N
  # Query_time: N.N  Lock_time: N.N Rows_sent: N  Rows_examined: N
  SET timestamp=N;
  select sleep(N)

#######################################################################

[root@localhost mysql_data]# mysqldumpslow  --help
Usage: mysqldumpslow [ OPTS... ] [ LOGS... ]

Parse and summarize the MySQL slow query log. Options are

  --verbose    verbose
  --debug      debug
  --help       write this text to standard output

  -v           verbose
  -d           debug
  -s ORDER     what to sort by (al, at, ar, c, l, r, t), 'at' is default #根据以下某个信息来排序
                al: average lock time
                ar: average rows sent
                at: average query time
                 c: count
                 l: lock time
                 r: rows sent
                 t: query time  
  -r           reverse the sort order (largest last instead of first)  # 逆序输出
  -t NUM       just show the top n queries      # TOP(n)参数
  -a           don't abstract all numbers to N and strings to 'S'
  -n NUM       abstract numbers with at least n digits within names
  -g PATTERN   grep: only consider stmts that include this string
  -h HOSTNAME  hostname of db server for *-slow.log filename (can be wildcard),
               default is '*', i.e. match all
  -i NAME      name of server instance (if using mysql.server startup script)
  -l           don't subtract lock time from total time
如果在线上操作，不需要mysqldumpslow去扫整个slow.log， 可以去tail -n 10000 slow.log > last_10000_slow.log(10000这个数字根据实际情况进行调整),然后进行mysqldumpslow last_10000_slow.log
慢查询日志存入表
--
-- 在my.cnf 中增加 log_output = TABLE，打开slow_query_log选项，然后重启数据库实例
--
mysql> show variables like "log_output%";
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| log_output    | TABLE |
+---------------+-------+
1 row in set (0.00 sec)

mysql> show variables like "slow_query_log";
+----------------+-------+
| Variable_name  | Value |
+----------------+-------+
| slow_query_log | ON    |
+----------------+-------+
1 row in set (0.00 sec)

mysql> select * from mysql.slow_log;
+----------------------------+---------------------------+-----------------+-----------------+-----------+---------------+----+----------------+-----------+-----------+-----------------+-----------+
| start_time                 | user_host                 | query_time      | lock_time       | rows_sent | rows_examined | db | last_insert_id | insert_id | server_id | sql_text        | thread_id |
+----------------------------+---------------------------+-----------------+-----------------+-----------+---------------+----+----------------+-----------+-----------+-----------------+-----------+
| 2015-11-20 19:50:28.574677 | root[root] @ localhost [] | 00:00:04.000306 | 00:00:00.000000 |         1 |             0 |    |              0 |         0 |        11 | select sleep(4) |         3 |
+----------------------------+---------------------------+-----------------+-----------------+-----------+---------------+----+----------------+-----------+-----------+-----------------+-----------+
1 row in set (0.00 sec)

mysql> show create table mysql.slow_log;
--
-- 表结构输出省略
-- 关键一句如下：
--
ENGINE=CSV DEFAULT CHARSET=utf8 COMMENT='Slow log'  -- ENGINE=CSV 这里使用的是CSV的引擎,性能较差

-- 建议将slow_log表的存储引擎改成MyISAM
mysql> alter table mysql.slow_log engine = myisam;
ERROR 1580 (HY000): You cannot 'ALTER' a log table if logging is enabled  '-- 提示我正在记录日志中，不能转换

mysql> set global slow_query_log = 0;    -- 先停止记录日志
Query OK, 0 rows affected (0.01 sec)

mysql> alter table mysql.slow_log engine = myisam;   -- 然后转换表的引擎
Query OK, 2 rows affected (5.05 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> set global slow_query_log = 1;     -- 再开启记录日志
Query OK, 0 rows affected (0.00 sec)

mysql> show create table mysql.slow_log;
--
-- 表结构输出省略
-- 关键一句如下：
--
ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Slow log'  -- ENGINE 变成了MyISAM
使用TABLE的优势在于方便查询，但是记住当在备份的时候，不要备份慢查询日志的表，避免备份过大。 
使用FILE也可以，需要定时清除该文件，避免单文件过大。
```



# 创建、显示、删除、连接数据库

create database <数据库名>  ; -----不能以数字开头----

## 查看建库语句

```sql
show create database oldboy\G;
```

## 创建GBK字符集的数据库

```sql
create database oldboy_gbk DEFAULT CHARACTER SET gbk COLATE gbk_chinese_ci;
```

## 创建UTF8字符集的数据库

```sql
create database oldboy_utf8 DEFAULT CHARACTER SET utf8 COLATE utf8_general_ci;
```

建的字符集
2、编译的时候指定字符集
3、编译时没有指定或指定不同的字符集时，指定字符集创建数据库。

## 显示数据库

```sql
help show databases;
show databases like '%oldboy%';
```

## 显示当前数据库

```sql
select database();
```

## 删除数据库

```sql
drop database oldboy;
```

## 连接数据库

```sql
use oldboy;
```

## 查看版本、用户、时间、表

```sql
select version();
select user();
select now();
show tables;
show tables like 'user';
show tables from oldboy; -----查看指定库的表------
show tables in oldboy;
```

## 删除数据库user

```sql
drop user "user"@"主机域"；
drop user "oldboy"@"localhost"；
-----------主机名首字母大写或特殊字符用以下方法删除---------
delete from mysql.user where user='oldboy' and host='localhost';
flush privileges;
```



# 表的操作

```sql
mysql> create table student(
id int(4) not null,
name char(20) not null,
age tinyint(2) not null default '0',
dept varchar(16) default null
);


mysql> show create table student\G
*************************** 1. row ***************************
       Table: student
Create Table: CREATE TABLE `student` (
  `id` int(4) NOT NULL,
  `name` char(20) NOT NULL,
  `age` tinyint(2) NOT NULL DEFAULT '0',
  `dept` varchar(16) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
1 row in set (0.01 sec)

mysql> desc student;
+-------+-------------+------+-----+---------+-------+
| Field | Type        | Null | Key | Default | Extra |
+-------+-------------+------+-----+---------+-------+
| id    | int(4)      | NO   |     | NULL    |       |
| name  | char(20)    | NO   |     | NULL    |       |
| age   | tinyint(2)  | NO   |     | 0       |       |
| dept  | varchar(16) | YES  |     | NULL    |       |
+-------+-------------+------+-----+---------+-------+
4 rows in set (0.04 sec)
```



# 索引操作

字符串类型查询要带引号，否则不走索引
1、要在表的列上创建索引
2、索引会加快查询速度，但会影响更新速度
3、索引不是越多越好，要在频繁查询的where后的条件列上创建索引
4、小表或唯一至极少的列上不建索引

## 创建索引

```sql
create table student(
id int(4) not null AUTO_INCREMENT,
name char(20) not null,
age tinyint(2) NOT NULL default '0',
dept varchar(16) default NULL,
primary key(id),
KEY index_name(name)
);

mysql> desc student;
+-------+-------------+------+-----+---------+----------------+
| Field | Type        | Null | Key | Default | Extra          |
+-------+-------------+------+-----+---------+----------------+
| id    | int(4)      | NO   | PRI(主键索引) | NULL    | auto_increment |
| name  | char(20)    | NO   | MUL（普通索引） | NULL    |                |
| age   | tinyint(2)  | NO   |     | 0       |                |
| dept  | varchar(16) | YES  |     | NULL    |                |
+-------+-------------+------+-----+---------+----------------+
4 rows in set (0.04 sec)
```

## 添加主键

```sql
alter table student change id id int primary key auto_increment;
```

## 删除索引

```sql
mysql> alter table student drop index index_name
Query OK, 0 rows affected (0.09 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc student;
+-------+-------------+------+-----+---------+----------------+
| Field | Type        | Null | Key | Default | Extra          |
+-------+-------------+------+-----+---------+----------------+
| id    | int(4)      | NO   | PRI | NULL    | auto_increment |
| name  | char(20)    | NO   |     | NULL    |                |
| age   | tinyint(2)  | NO   |     | 0       |                |
| dept  | varchar(16) | YES  |     | NULL    |                |
+-------+-------------+------+-----+---------+----------------+
```

## 添加索引

```sql
mysql> alter table student add index index_name(name);
Query OK, 0 rows affected (0.09 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc student;
+-------+-------------+------+-----+---------+----------------+
| Field | Type        | Null | Key | Default | Extra          |
+-------+-------------+------+-----+---------+----------------+
| id    | int(4)      | NO   | PRI | NULL    | auto_increment |
| name  | char(20)    | NO   | MUL | NULL    |                |
| age   | tinyint(2)  | NO   |     | 0       |                |
| dept  | varchar(16) | YES  |     | NULL    |                |
+-------+-------------+------+-----+---------+----------------+
4 rows in set (0.00 sec)

mysql> create index index_dept on student(dept(8));
Query OK, 0 rows affected (0.12 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc student;
+-------+-------------+------+-----+---------+----------------+
| Field | Type        | Null | Key | Default | Extra          |
+-------+-------------+------+-----+---------+----------------+
| id    | int(4)      | NO   | PRI | NULL    | auto_increment |
| name  | char(20)    | NO   | MUL | NULL    |                |
| age   | tinyint(2)  | NO   |     | 0       |                |
| dept  | varchar(16) | YES  | MUL | NULL    |                |
+-------+-------------+------+-----+---------+----------------+
4 rows in set (0.00 sec
```

## 创建联合索引

```sql
create index index_name_dept on student(name,dept);
Query OK, 0 rows affected (0.07 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> show create index/G;
....................省略号.............................
******************** 4. row ***************************
        Table: student
   Non_unique: 1
     Key_name: index_name_dept 
.....................省略号............................
```

## 指定字符创建联合索引

```sql
mysql> drop index index_name_dept on student;
Query OK, 0 rows affected (0.12 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> create index ind_name_dept on student(name(8),dept(10));
Query OK, 0 rows affected (0.04 sec)
Records: 0  Duplicates: 0  Warnings: 0

提示：按条件列查询数据时，联合索引是有前缀生效特性的
index(a,b,c)仅a,ab,abc三个条件列可以走索引。b,bc,ac,c等无法走索引
```

## 创建非主键唯一索引（约束表内容）

```sql
mysql> create unique index uni_ind_name on student;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '' at line 1
mysql> create unique index uni_ind_name on student(name);
Query OK, 0 rows affected (0.04 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc student;
+-------+-------------+------+-----+---------+----------------+
| Field | Type        | Null | Key | Default | Extra          |
+-------+-------------+------+-----+---------+----------------+
| id    | int(4)      | NO   | PRI | NULL    | auto_increment |
| name  | char(20)    | NO   | UNI | NULL    |                |
| age   | tinyint(2)  | NO   |     | 0       |                |
| dept  | varchar(16) | YES  | MUL | NULL    |                |
+-------+-------------+------+-----+---------+----------------+
4 rows in set (0.00 sec)
```



# INSERT、DELETE、SELECT、UPDATE

```sql
CREATE TABLE test (
id int(4) NOT NULL AUTO_INCREMENT,
name char(20) NOT NULL,
PRIMARY KEY (id)
);

insert into test(id,name) values(1,'oldboy');
mysql> select * from test;
+----+--------+
| id | name   |
+----+--------+
|  1 | oldboy |
+----+--------+
1 row in set (0.03 sec)

主键列自增
mysql> insert into test(name) values('oldgirl');
Query OK, 1 row affected (0.01 sec)

mysql> select * from test;
+----+---------+
| id | name    |
+----+---------+
|  1 | oldboy  |
|  2 | oldgirl |
+----+---------+
2 rows in set (0.00 sec)

mysql> insert into test values(3,'inca');
Query OK, 1 row affected (0.00 sec)

mysql> select * from test;
+----+---------+
| id | name    |
+----+---------+
|  1 | oldboy  |
|  2 | oldgirl |
|  3 | inca    |
+----+---------+
3 rows in set (0.00 sec)

mysql> insert into test values(4,'zuma'),(5,'kaka');
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> select * from test;
+----+---------+
| id | name    |
+----+---------+
|  1 | oldboy  |
|  2 | oldgirl |
|  3 | inca    |
|  4 | zuma    |
|  5 | kaka    |
+----+---------+
5 rows in set (0.00 sec)


delete
delete from test;

SELECT
字符串类型查询要带引号，否则不走索引


update
mysql> update test set name='gongli' where id=3;    --------不加where条件name字段全被修改-------

mysql> select * from test;
+----+---------+
| id | name    |
+----+---------+
|  3 | gongli  |
|  5 | kaka    |
|  1 | oldboy  |
|  6 | oldgirl |
|  4 | zuma    |
+----+---------+
```



# 多表查询实例

```sql
mysql> select student.sno,student.sname,course.cname,sc.grade 
    -> from student,sc,course
    -> where student.sno=sc.sno and course.cno=sc.cno
    -> order by sno;
+-----+---------+----------------------+-------+
| sno | sname   | cname                | grade |
+-----+---------+----------------------+-------+
|   1 | 宏志    | linux中高级运维      |     4 |
|   1 | 宏志    | mysql高级dba         |     1 |
|   1 | 宏志    | linux高级架构师      |     3 |
|   1 | 宏志    | python运维开发       |     6 |
|   2 | 王硕    | linux高级架构师      |     2 |
|   2 | 王硕    | python运维开发       |     8 |
|   2 | 王硕    | linux中高级运维      |     3 |
|   2 | 王硕    | mysql高级dba         |     2 |
|   3 | odlboy  | linux高级架构师      |     4 |
|   3 | odlboy  | python运维开发       |     8 |
|   3 | odlboy  | linux中高级运维      |     4 |
|   3 | odlboy  | mysql高级dba         |     2 |
|   4 | 脉动    | linux中高级运维      |     1 |
|   4 | 脉动    | mysql高级dba         |     2 |
|   4 | 脉动    | linux高级架构师      |     1 |
|   4 | 脉动    | python运维开发       |     3 |
|   5 | oldgirl | linux高级架构师      |     3 |
|   5 | oldgirl | python运维开发       |     9 |
|   5 | oldgirl | linux中高级运维      |     5 |
|   5 | oldgirl | mysql高级dba         |     2 |
+-----+---------+----------------------+-------+
20 rows in set (0.00 sec)


---------------------------------建表语句-----------------------------------
mysql> create table student(
    -> sno int(10) NOT NULL COMMENT '学号',
    -> sname varchar(16) NOT NULL COMMENT '姓名',
    -> ssex char(2) NOT NULL COMMENT '性别',
    -> sage tinyint(2) NOT NULL default '0' COMMENT '学生年龄',
    -> sdept varchar(16) default NULL COMMENT '学生所在系别',
    -> PRIMARY KEY (sno),
    -> key index_sname (sname)
    -> );
Query OK, 0 rows affected (0.12 sec)


create table course(
cno int(10) NOT NULL COMMENT '课程号',
cname varchar(64) NOT NULL COMMENT '课程名',
ccredi tinyint(2) NOT NULL COMMENT '学分',
PRIMARY KEY (cno)
);


mysql> create table `sc` (
    -> scid int(12) NOT NULL auto_increment COMMENT '主键',
    -> `cno` int(10) NOT NULL COMMENT '课程号',
    -> `sno` int(10) NOT NULL COMMENT '学号',
    -> `grade` tinyint(2) NOT NULL COMMENT '学生成绩',
    -> PRIMARY KEY (`scid`)
    -> );
Query OK, 0 rows affected (0.13 sec)

insert into student values(0001,'宏志','男',30,'计算机网络');
insert into student values(0002,'王硕','男',30,'computer app');
insert into student values(0003,'odlboy','男',28,'物流管理');
insert into student values(0004,'脉动','男',29,'computer app');
insert into student values(0005,'oldgirl','女',26,'计算机科学与技术');
insert into student values(0006,'莹莹','女',22,'护士');
insert into student values(0010,'baktest','女',100,'test');

insert into course values(1001,'linux中高级运维',3);
insert into course values(1002,'linux高级架构师',5);
insert into course values(1003,'mysql高级dba',4);
insert into course values(1004,'python运维开发',4);
insert into course values(1005,'java web',3);

insert into sc(sno,cno,grade) values(0001,1001,4);
insert into sc(sno,cno,grade) values(0001,1002,3);
insert into sc(sno,cno,grade) values(0001,1003,1);
insert into sc(sno,cno,grade) values(0001,1004,6);

insert into sc(sno,cno,grade) values(0002,1001,3);
insert into sc(sno,cno,grade) values(0002,1002,2);
insert into sc(sno,cno,grade) values(0002,1003,2);
insert into sc(sno,cno,grade) values(0002,1004,8);

insert into sc(sno,cno,grade) values(0003,1001,4);
insert into sc(sno,cno,grade) values(0003,1002,4);
insert into sc(sno,cno,grade) values(0003,1003,2);
insert into sc(sno,cno,grade) values(0003,1004,8);

insert into sc(sno,cno,grade) values(0004,1001,1);
insert into sc(sno,cno,grade) values(0004,1002,1);
insert into sc(sno,cno,grade) values(0004,1003,2);
insert into sc(sno,cno,grade) values(0004,1004,3);

insert into sc(sno,cno,grade) values(0005,1001,5);
insert into sc(sno,cno,grade) values(0005,1002,3);
insert into sc(sno,cno,grade) values(0005,1003,2);
insert into sc(sno,cno,grade) values(0005,1004,9);
```



# 执行计划

```sql
字符串类型查询要带引号，否则不走索引

mysql> explain select * from test where name='oldboy'\G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: test
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 5
        Extra: Using where
1 row in set (0.02 sec)

mysql> create index index_name on test(name);

mysql> explain select * from test where name='oldboy'\G;
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: test
         type: ref
possible_keys: index_name             ------可能使用索引------
          key: index_name                      ------使用的索引-------
      key_len: 80                                    ------索引长度-------
          ref: const
         rows: 1                                        ------扫描的行数--------
        Extra: Using where; Using index
```

# Mysql 修改字段长度、修改列名、新增列、修改自增主键起始值

## 1、alter table 表名 modify column 字段名 类型;

```sql
例如
数据库中user表 name字段是varchar(30)
可以用
alter table user modify column name varchar(50) ; --修改字段长度
alter table test change  column address address1 varchar(30)--修改表列名
alter table test add  column name varchar(10); --添加表列  
```

## 2、MySQL 脚本实现  字段默认系统时间 用例 

```sql
--添加CreateTime 设置默认时间 CURRENT_TIMESTAMP 
ALTER TABLE `table_name`
ADD COLUMN  `CreateTime` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' ;

--修改CreateTime 设置默认时间 CURRENT_TIMESTAMP 
ALTER TABLE `table_name`
M
MODIFY COLUMN  `CreateTime` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' ;
如果设定不了， 请将 DATETIME改为TIMESTAMP。
```

## 3.mySql 设置表的自增主键的起始值

```sql
alter table    表名  AUTO_INCREMENT = 1000;
mysql> alter table test add sex char(4);
mysql> alter table test add age int(4) after name;
mysql> desc test;
+-------+----------+------+-----+---------+----------------+
| Field | Type     | Null | Key | Default | Extra          |
+-------+----------+------+-----+---------+----------------+
| id    | int(4)   | NO   | PRI | NULL    | auto_increment |
| name  | char(20) | NO   |     | NULL    |                |
| age   | int(4)   | YES  |     | NULL    |                |
| sex   | char(4)  | YES  |     | NULL    |                |
+-------+----------+------+-----+---------+----------------+

mysql> desc test;
+-------+-------------+------+-----+---------+----------------+
| Field | Type        | Null | Key | Default | Extra          |
+-------+-------------+------+-----+---------+----------------+
| qq    | varchar(15) | YES  |     | NULL    |                |
| id    | int(4)      | NO   | PRI | NULL    | auto_increment |
| name  | char(20)    | NO   |     | NULL    |                |
| age   | int(4)      | YES  |     | NULL    |                |
| sex   | char(4)     | YES  |     | NULL    |                |
+-------+-------------+------+-----+---------+----------------+

mysql> rename table test to test1；
mysql> show tables;
+------------------+
| Tables_in_oldboy |
+------------------+
| course           |
| sc               |
| student          |
| test1            |
+------------------+

mysql> alter table test1 renanme to test
```

#  备份、恢复

## 备份

```sql
[root@localhost opt]# /mysql/bin/mysqldump -uroot -ptest01 -B --set-gtid-purged=off  oldboy >/opt/oldboy_bak.sql

查看dump备份信息
[root@localhost ~]# grep -E -v "#|\/|^$|--" /opt/oldboy_bak.sql
USE `oldboy`;
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `name` char(20) NOT NULL,
  `age` tinyint(2) NOT NULL DEFAULT '0',
  `dept` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uni_ind_name` (`name`),
  KEY `index_dept` (`dept`(8)),
  KEY `ind_name_dept` (`name`(8),`dept`(10))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
LOCK TABLES `student` WRITE;
UNLOCK TABLES;
DROP TABLE IF EXISTS `test`;
CREATE TABLE `test` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `name` char(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;
LOCK TABLES `test` WRITE;
UNLOCK TABLES;
```

## 恢复

```sql
将备份文件恢复至数据库
mysql -uroot -ptest01 oldboy </opt/oldboy_bak.sql 
将备份之后的增量数据bin.log输出至bin.sql
 /mysql/bin/mysqlbinlog -d oldboy  bin.000012 >./bin.sql
编辑bin.sql根据时间戳或关键字删除不需要的语句后恢复至数据库
mysql -uroot -ptest01 oldboy <bin.sql

   -------报WARNING: The option --database has been used. It may filter parts of transactions, but will include the GTIDs in any case. If you want to exclude or include transactions, you should use the options --exclude-gtids or --include-gtids, respectively, instead.错误时执行以下语句----------------
 /mysql/bin/mysqlbinlog -d oldboy --skip-gtids=true  bin.000012 >./bin.sql
```



## 实例

***-F  刷新binlog******

***-A  备份所有库***

***刷新binlog--master-data***
***记录全备时binlog的位置便于继续增量恢复***
***/mysql/bin/mysqldump -uroot -p'test01' --master-data=1 oldboy*** 

***避免锁表：--single-transaction***
***innodb:***
***/mysql/bin/mysqldump -uroot -p'test01' -A -B --master-data=1 --events --single-transaction|gzip>/opt/all.sql.gz****

### 备份oldboy库

mysqldump -uroot -p'test01' oldboy > /opt/mysql_bak.sql
加-B参数，自动备份建库语句,导入时自动建库
mysqldump -uroot -p'test01' -B oldboy > /opt/mysql_bak_B.sql
备份多个数据库
/mysqldump -uroot -p'test01' -B oldboy oldgril > /opt/mysql_bak_boy_gril.sql
压缩备份
mysqldump -uroot -p'test01' -f -B oldboy|gzip > /opt/mysql_bak_B.sql.gz
筛选备份数据库
mysql -e "show databases;" -uroot -ppassword|grep -Ev "Database|information_schema|mysql|db1|db2"| xargs mysqldump -uroot -ppassword --databases > mysql_dump.sql

### 导入oldboy库

mysql -uroot -p'test01' oldboy </opt/mysql_bak.sql
出现ERROR 1840 (HY000) at line 24: @@GLOBAL.GTID_PURGED can only be set when @@GLOBAL.GTID_EXECUTED is empty.错误时加-f
mysql -uroot -p'test01' -f oldboy</opt/mysql_bak.sql


技巧
显示所有数据库并随mysqldump打印
mysql -uroot -p'test01' -e "show databases;"|grep -Evi "database|infor|perfor"|sed 's#^#mysqldump -uroot -p'test01' -B#g'
分库备份脚本：
mysql -uroot -p'test01' -e "show databases;"|grep -Evi "database|infor|perfor"|sed -r 's#^([a-z].*$)#mysqldump -uroot -p'test01' --events -B \1|gzip >/opt/bak/\1.sql.gz#g'|bash
for循环分库备份
for dbname in `mysql -uroot -p'test01' -e "show databases;"|grep -Evi "database|infor|perfor"`
do
mysqldump -uroot -p'test01' --events -B $dbname|gzip >/opt/bak/${dbname}_bak.sql.gz
done

### 备份表

备份oldboy下面的student表
/mysql/bin/mysqldump -uroot -p'test01' oldboy student > /opt/table_student.sql
备份多个表
备份oldboy下面的student和test表
/mysql/bin/mysqldump -uroot -p'test01' oldboy student test > /opt/table_student&test.sql

备份表结构 -d
/mysql/bin/mysqldump -uroot -p'test01' -d oldboy student > /opt/table_student.sql
备份表数据 -t
/mysql/bin/mysqldump -uroot -p'test01' -t oldboy student > /opt/table_student.sql

### 恢复

source /opt/mysql_bak_B.sql

for循环恢复分库备份 从备份文件取数据库名
for dbnamein `ls *.sql|sed 's#_bak.sq##g'`
do mysql -uroot -p'test01' < ${dbname}_bak.sql
done

### 查看数据库连接情况

show full processlist

### 查看状态

show global status

### 查看参数

show variables



# 设置别名

alias mysql='mysql -U' 
永久生效需要写入到/etc/profile.d/bashrc



# BENCHMARK

```sql
如果你的问题是与具体MySQL表达式或函数有关，可以使用mysql客户程序所带的BENCHMARK()函数执行定时测试。其语法为BENCHMARK(loop_count,expression)。例如：
mysql> SELECT BENCHMARK(1000000,1+1)；
+------------------------+| 
BENCHMARK(1000000,1+1) 
|+------------------------+|?????????????????????
                    0 
|+------------------------+
1 row in set (0.32 sec)
上面结果在PentiumII 400MHz系统上获得。它显示MySQL在该系统上在0.32秒内可以执行1,000,000个简单的+表达式运算。
 所有MySQL函数应该被高度优化，但是总有可能有一些例外。BENCHMARK()是一个找出是否查询有问题的优秀的工具

mysql> SELECT BENCHMARK(1000000000,"select * from oldboy.student");
+--------------------------------------------------------------+
| BENCHMARK(1000000000,"select * from oldboy.student") |
+--------------------------------------------------------------+
|                                                                                      0 |
+--------------------------------------------------------------+
1 row in set (5.81 sec)
```



# 字符集

```sql
#my.cnf中配置character_set_server=utf8mb4  服务端永久生效


防止乱码需先执行set names 库表的字符集！
两种方法

1.
[root@localhost opt]# vi test.sql
set names utf8mb4;   #
INSERT INTO student VALUES (8,'老女孩');
mysql> source /opt/test.sql
mysql> select * from student;
+----+-----------+
| id | name      |
+----+-----------+
|  1 | oldboy    |
|  3 | inca      |
|  4 | zuma      |
|  5 | kaka      |
|  6 | 老男孩    |
|  7 | oldgirl   |
|  8 | 老女孩    |
+----+-----------+
7 rows in set (0.00 sec)

2.
[root@localhost opt]# vi test.sql
INSERT INTO student VALUES (9,'张三');
mysql -uroot -ptest01 --default-character-set=utf8mb4 oldboy < /opt/test.sql

mysql> show variables like 'character_set%';
+--------------------------+------------------------+
| Variable_name            | Value                  |
+--------------------------+------------------------+
| character_set_client     | utf8                       | #客户端字符集     ----------客户端，mysql随系统字符集，由set names 更改
| character_set_connection | utf8                   | #连接字符集      ----------客户端，mysql随系统字符集，由set names 更改
| character_set_database   | utf8mb4              | #数据库字符集，配置文件指定或建库建表指定 -----------服务端
| character_set_filesystem | binary                    | 
| character_set_results    | utf8                       | #返回结果字符集      ----------客户端，mysql随系统字符集，由set names 更改
| character_set_server     | utf8mb4                   | #服务端字符集，配置文件指定或建库建表指定  ----------服务端
| character_set_system     | utf8                        |
| character_sets_dir       | /mysql/share/charsets/ |
+--------------------------+------------------------+
8 rows in set (0.28 sec)

----------查看系统字符集--------------
[root@localhost ~]# cat /etc/sysconfig/i18n 
LANG="en_US.UTF-8"
SYSFONT="latarcyrheb-sun16"

 修改表的字符集：alter table nagios_externalcommands  charset=utf8mb4;
 改变表现有数据字符集：alter table nagios_externalcommands  convert to character set utf8mb4;
 修改字段字符集：alter table nagios_externalcommands change command_args command_args VARCHAR(128) CHARACTER SET utf8mb4;
```

# binlog

```sql
binlog
-d :指定库

flush 刷新log日志，自此刻开始产生一个新编号的binlog日志文件;
　　　　flush logs;
　　　　　　注意：每当mysqld服务重启时，会自动执行此命令，刷新binlog日志；在mysqlddump备份数据时加-F选项也会刷新binlog日志；

查看二进制binlog文件  
show binlog events in 'binlog.000021'

将行（row）级二进制binlog文件转换为可读文件并显示所有的dml操作
mysqlbinlog bin.000021 -vv --base64-output=decode-rows > bin21.sql

基于位置点的binlog恢复命令,指定库
mysqlbinlog --start-position="4" --stop-position="1427" -d oldboy  bin.000021 | mysql -uroot -p123456 oldboy -S /data/3306/mysql.sock

4、MySQL企业binlog模式的选择
互联网公司使用MySQL的功能较少（不用存储过程、触发器、函数），选择默认的Statement level
用到MySQL的特殊功能（存储过程、触发器、函数）则选择Mixed模式
用到MySQL的特殊功能（存储过程、触发器、函数），又希望数据最大化一直则选择Row模式
```

# mysql的几种存储引擎的特点

![image-20210114095423246](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210114095423246.png)



# 查询库大小

```sql
select table_schema, concat(truncate(sum(data_length)/1024/1024,2),' mb') as data_size,
concat(truncate(sum(index_length)/1024/1024,2),'mb') as index_size
from information_schema.tables
group by table_schema
order by data_length desc;

查询某个库大小
mysql查看当前某个数据库和数据库下所有的表的大小

select table_name, concat(truncate(data_length/1024/1024,2),' mb') as data_size,
concat(truncate(index_length/1024/1024,2),' mb') as index_size
from information_schema.tables where table_schema = 'mysql'
group by table_name
order by data_length desc;
```



