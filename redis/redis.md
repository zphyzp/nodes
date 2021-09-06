# 部署

```shell
make && make install

#复制redis配置文件
mkdir redis-config

#指定使用该配置文件启动
cp /root/redis-6.0.6/redis.conf /usr/local/bin/redis-config/

#修改配置文件，为后台启动
daemonize yes

#通过指定配置文件启动
redis-server redis-config/redis.conf

#客户端连接
 redis-cli -p 6379
 
 #测试ping
 127.0.0.1:6379> ping
 PONG
 
 #测试key
 127.0.0.1:6379> set name zp
 OK
 127.0.0.1:6379> get name
 "zp"
 127.0.0.1:6379> keys *
 1) "name"
```

# 测试性能

```shell
#测试50个并发，每个并发10000条请求
redis-benchmark -h localhost -p 6379 -c 100 -n 100000
```

![](F:\软件\Typora\image\redis-bench.png)

# 基础知识

> redis是单线程的，基于内存操作，机器的内存和网络带宽是瓶颈，CPU不是性能瓶颈。

```shell
#切换至3号数据库
select 3

#查看数据库大小
DBSIZE

flushdb  #清除当前数据库
flushall #清楚全部数据库
```

# 数据类型

```shell
127.0.0.1:6379> set name zp #set key
OK
127.0.0.1:6379> get name #查看当前key的值
"zp"
127.0.0.1:6379> set age 1
OK
127.0.0.1:6379> keys * #查看当前所有key
1) "age"
2) "name"
127.0.0.1:6379> EXISTS name #判断当前key是否存在
(integer) 1
127.0.0.1:6379> EXISTS name1
(integer) 0
127.0.0.1:6379> move name 1 #移除当前key
(integer) 1
127.0.0.1:6379> EXISTS name #判断当前key是否存在，1为存在
(integer) 0
127.0.0.1:6379> EXPIRE name 10 #设置key的过期时间，单位为s
(integer) 1
127.0.0.1:6379> ttl name #查看当前key的剩余时间，-2为已过期
(integer) -2
127.0.0.1:6379> type name #查看当前key的类型
string
127.0.0.1:6379> type age
string
```

## string（字符串）

```shell
#####################################################################################################
127.0.0.1:6379> set key1 v1
OK
127.0.0.1:6379> get key1
"v1"
127.0.0.1:6379> EXISTS key1
(integer) 1
127.0.0.1:6379> APPEND key1 "hello"   #向key中追加字符串，若是当前key不存在则相当于set key
(integer) 7
127.0.0.1:6379> get key1
"v1hello"
127.0.0.1:6379> STRLEN key1   #查看字符串长度
(integer) 7
127.0.0.1:6379> APPEND key1 ",zp"
(integer) 10
127.0.0.1:6379> STRLEN key1
(integer) 10
127.0.0.1:6379> get key1
"v1hello,zp"
#####################################################################################################
#i++ 步长
127.0.0.1:6379> set views 0
OK
127.0.0.1:6379> get views
"0"
127.0.0.1:6379> INCR views #自增1
(integer) 1
127.0.0.1:6379> INCR views
(integer) 2
127.0.0.1:6379> INCR views
(integer) 3
127.0.0.1:6379> get views
"3"
127.0.0.1:6379> DECR views #自减1
(integer) 2
127.0.0.1:6379> DECR views
(integer) 1
127.0.0.1:6379> get views
"1"
127.0.0.1:6379> INCRBY views 10 #设置步长，指定增量
(integer) 11
127.0.0.1:6379> deCRBY views 10 #设置步长，指定减量
(integer) 1
127.0.0.1:6379> deCRBY views 10
(integer) -9
127.0.0.1:6379> INCRBY views 20  
(integer) 11
#####################################################################################################
#字符串范围 range
127.0.0.1:6379> set key1 hellozp
OK
127.0.0.1:6379> get key1
"hellozp"
127.0.0.1:6379> GETRANGE key1 0 3 #截取字符串第0到3
"hell"
127.0.0.1:6379> GETRANGE key1 0 -1 #截取全部字符串，和get key1一样
"hellozp"

127.0.0.1:6379> set key2 abcdefg
OK
127.0.0.1:6379> SETRANGE key2 1 xxxxx #替换指定位置开始得字符串
(integer) 7
127.0.0.1:6379> get key2
"axxxxxg"
127.0.0.1:6379> 
#####################################################################################################
#setex 设置过期时间
#setnx 如果未设置会创建，存在则创建失败
127.0.0.1:6379> setex key3 30 "hello" #设置一个key3，30s后过期
OK
127.0.0.1:6379> get key3
"hello"
127.0.0.1:6379> ttl key3
(integer) 19
127.0.0.1:6379> setnx mykey "redis" #设置一个mykey，如果不存在则为redis
(integer) 1 #返回1为成功
127.0.0.1:6379> get key3
(nil)
127.0.0.1:6379> setnx mykey "mongo" #设置一个mykey，因为已存在，则失败
(integer) 0 #返回0为失败
127.0.0.1:6379> get mykey
"redis"
#####################################################################################################
127.0.0.1:6379> MSET k1 v1 k2 v2 k3 v3 #同时设置多个值
OK
127.0.0.1:6379> keys *
1) "k3"
2) "k2"
3) "k1"
127.0.0.1:6379> MGET k1 k2 k3 #同时获取多个值
1) "v1"
2) "v2"
3) "v3"
127.0.0.1:6379> MSETNX k1 v1 k4 v4 #同时设置多个，若存在则失败，一个失败则全失败
(integer) 0
127.0.0.1:6379> keys *
1) "k3"
2) "k2"
3) "k1"

# 对象
set user:1 {name:zp,age:13} #设置user:1对象 值为json字符来保存一个对象
OK

# user:[id]:[filed]
127.0.0.1:6379> mget user:1
1) "{name:zp,age:123}"
127.0.0.1:6379> mset user:1:name zp user:1:age 11 #利用mset设置多个对象，存储不同得值
OK
127.0.0.1:6379> mget user:1 user:1:name user:1:age #根据不同得对象的key获取值
1) "{name:zp,age:123}"
2) "zp"
3) "11"
#####################################################################################################
#组合命令 getset 先获取再设置
127.0.0.1:6379> getset db redis #若不存在返回nil，并设置一个为redis值
(nil)
127.0.0.1:6379> get db
"redis"
127.0.0.1:6379> getset db mongo #返回为redis值，后并更新为mongo值
"redis"
127.0.0.1:6379> get db
"mongo"
#####################################################################################################

```

## list(列表)

```shell
#list
#####################################################################################################

127.0.0.1:6379> LPUSH list one #将一个或多个值插入列表头部（左）
(integer) 1
127.0.0.1:6379> LPUSH list two
(integer) 2
127.0.0.1:6379> LPUSH list three
(integer) 3
127.0.0.1:6379> LRANGE list 0 -1 #获取list中的值，通过区间获取特定的值
1) "three"
2) "two"
3) "one"
127.0.0.1:6379> RPUSH list right #将一个或多个值插在列表尾部（右）
(integer) 4
127.0.0.1:6379> LRANGE list 0 -1
1) "three"
2) "two"
3) "one"
4) "right"
127.0.0.1:6379> 
#####################################################################################################
127.0.0.1:6379> LRANGE list 0 -1 
1) "three"
2) "two"
3) "one"
4) "right"
127.0.0.1:6379> lpop list #移除list中的第一（左边）个元素
"three"
127.0.0.1:6379> rpop list #移除list中的最后一个（右边）元素
"right"
127.0.0.1:6379> LRANGE list 0 -1
1) "two"
2) "one"
#####################################################################################################
#通过下标获取值
127.0.0.1:6379> LINDEX list 0 
"two"
127.0.0.1:6379> LINDEX list 1
"one"
#####################################################################################################
#返回list的长度
127.0.0.1:6379> LRANGE list 0 -1
1) "four"
2) "three"
3) "two"
4) "one"
127.0.0.1:6379> llen list
(integer) 4
127.0.0.1:6379> 
#####################################################################################################
#移除指定值
127.0.0.1:6379> lrem list 1 one #移除一个one值
(integer) 1
127.0.0.1:6379> LRANGE list 0 -1 
1) "four"
2) "four"
3) "three"
4) "two"
127.0.0.1:6379> lrem list 2 four #移除两个four值
(integer) 2
#####################################################################################################
#保留指定值
127.0.0.1:6379> rpush mylist hello
(integer) 1
127.0.0.1:6379> rpush mylist hello1
(integer) 2
127.0.0.1:6379> rpush mylist hello2
(integer) 3
127.0.0.1:6379> rpush mylist hello3
(integer) 4
127.0.0.1:6379> LRANGE mylist 0 -1
1) "hello"
2) "hello1"
3) "hello2"
4) "hello3"
127.0.0.1:6379> ltrim mylist 1 2 #截取1和2的值（删除了0和3的值）
OK
127.0.0.1:6379> LRANGE mylist 0 -1
1) "hello1"
2) "hello2"
#####################################################################################################
# rpoplpush移除最后一个值添加到另一个list中
127.0.0.1:6379> lpush mylist hello
(integer) 3
127.0.0.1:6379> LRANGE mylist 0 -1
1) "hello"
2) "hello1"
3) "hello2"
127.0.0.1:6379> rpoplpush mylist otherlist
"hello2"
127.0.0.1:6379> LRANGE mylist 0 -1
1) "hello"
2) "hello1"
127.0.0.1:6379> LRANGE otherlist 0 -1
1) "hello2"
127.0.0.1:6379> 
#####################################################################################################
# lset
127.0.0.1:6379> EXISTS list #list不存在
(integer) 0
127.0.0.1:6379> lset list 0 item #因不存在，无法向0下表添加至
(error) ERR no such key
127.0.0.1:6379> lpush list redis #创建一个list并添加一个值redis
(integer) 1
127.0.0.1:6379> lset list 0 item #利用lset将redis值替换为item
OK
127.0.0.1:6379> lset list 1 otehr #再次向下标1添加other值，因下标1不存在，故添加失败
(error) ERR index out of range
127.0.0.1:6379> lrange list 0 -1
1) "item"
#####################################################################################################
#插入一个值linsert
127.0.0.1:6379> RPUSH mylist "hello"
(integer) 1
127.0.0.1:6379> RPUSH mylist "world"
(integer) 2
127.0.0.1:6379> LINSERT mylist before "world" "zp" #在world之前插入zp
(integer) 3
127.0.0.1:6379> LRANGE mylist 0 -1
1) "hello"
2) "zp"
3) "world"
127.0.0.1:6379> LINSERT mylist after "hello" "cool" #在hello之后插入cool
(integer) 4
127.0.0.1:6379> LRANGE mylist 0 -1
1) "hello"
2) "cool"
3) "zp"
4) "world"
```

## set

> set中的值无序、不重复

```bash
127.0.0.1:6379> sadd myset "hello" #增加一个值
(integer) 1
127.0.0.1:6379> sadd myset "zp"
(integer) 1
127.0.0.1:6379> sadd myset "3q"
(integer) 1
127.0.0.1:6379> SMEMBERS myset #查看
1) "3q"
2) "hello"
3) "zp"
127.0.0.1:6379> SisMEMBER myset zp #指定值查看是否存在，1为存在，0为不存在
(integer) 1
127.0.0.1:6379> SisMEMBER myset hello
(integer) 1
127.0.0.1:6379> SisMEMBER myset hello1
(integer) 0
#####################################################################################################
127.0.0.1:6379> scard myset #获取集合中的元素个数
(integer) 3
127.0.0.1:6379> sadd myset 4q
(integer) 1
127.0.0.1:6379> scard myset
(integer) 4
#####################################################################################################
127.0.0.1:6379> srem myset hello #移除set中的指定元素
(integer) 1
127.0.0.1:6379> SCARD myset
(integer) 3
127.0.0.1:6379> SMEMBERS myset
1) "3q"
2) "4q"
3) "zp"
#####################################################################################################
127.0.0.1:6379> SRANDMEMBER myset #随机抽选元素
"zp"
127.0.0.1:6379> SRANDMEMBER myset
"4q"
127.0.0.1:6379> SRANDMEMBER myset
"4q"
127.0.0.1:6379> SRANDMEMBER myset
"3q"
#####################################################################################################
#随机删除set中的元素
27.0.0.1:6379> spop myset
"zp"
127.0.0.1:6379> spop myset
"3q"
127.0.0.1:6379> SMEMBERS myset
1) "4q"
#####################################################################################################
#将一个指定值移动到另一个set中
127.0.0.1:6379> sadd myset2 "5q"
(integer) 1
127.0.0.1:6379> smove myset myset2 "3q"
(integer) 1
127.0.0.1:6379> SMEMBERS myset2
1) "3q"
2) "5q"
#####################################################################################################
#微博、B站，共同关注
127.0.0.1:6379> sadd kye1 a
(integer) 1
127.0.0.1:6379> sadd kye1 b
(integer) 1
127.0.0.1:6379> sadd kye1 c
(integer) 1
127.0.0.1:6379> sadd kye1 d
(integer) 1
127.0.0.1:6379> sadd kye2 c
(integer) 1
127.0.0.1:6379> sadd kye2 d
(integer) 1
127.0.0.1:6379> sadd kye2 e
(integer) 1
127.0.0.1:6379> sadd kye2 f
(integer) 1
127.0.0.1:6379> sdiff kye1 kye2  #kye1与kye2差集
1) "a"
2) "b"
127.0.0.1:6379> SINTER kye1 kye2 #交集
1) "c"
2) "d"
127.0.0.1:6379> sdiff kye2 kye1 #kye2与kye1茶几
1) "e"
2) "f"
127.0.0.1:6379> SUNION kye1 kye2 #并集
1) "b"
2) "d"
3) "e"
4) "c"
5) "f"
6) "a"
```

## hash

> map集合，key-map集合

> hash更适合存对象，string更是存字符串。

```bash
#####################################################################################################
127.0.0.1:6379> HSET myhash field1 "zp" #set一个具体的key-value
(integer) 1
127.0.0.1:6379> HGET myhash field1
"zp"
127.0.0.1:6379> HmSet myhash field1 "hello" field2 world #同时set多个key-value
OK
127.0.0.1:6379> HmGET myhash field1 field2
1) "hello"
2) "world"
127.0.0.1:6379> HGETALL myhash #同时get多个key-value
1) "field1"
2) "hello"
3) "field2"
4) "world"
#####################################################################################################
#删除指定的key，对应的值也删除
127.0.0.1:6379> HDEL myhash field1
(integer) 1
127.0.0.1:6379> HGETALL myhash
1) "field2"
2) "world"
#####################################################################################################
# 获取长度
127.0.0.1:6379> HLEN myhash #获取key长度
(integer) 1
127.0.0.1:6379> HMSET myhash field1 hello field2 world
OK
127.0.0.1:6379> HGETall myhash
1) "field2"
2) "world"
3) "field1"
4) "hello"
127.0.0.1:6379> HLEN myhash #获取hash表的字段数量
(integer) 2
#####################################################################################################
#判断hash中指定的key是否存在，1存在，0不存在
127.0.0.1:6379> HEXISTS myhash field1
(integer) 1
127.0.0.1:6379> HEXISTS myhash field3
(integer) 0
#####################################################################################################
#只获取key
127.0.0.1:6379> HKEYS myhash
1) "field2"
2) "field1"
#只获取value
127.0.0.1:6379> HVALS myhash
1) "world"
2) "hello"
#####################################################################################################
# 自增
127.0.0.1:6379> hset myhash field3 5
(integer) 1
127.0.0.1:6379> HINCRBY myhash field3 1
(integer) 6
127.0.0.1:6379> HINCRBY myhash field3 -3
(integer) 3
#####################################################################################################
#如果存在则不创建，不存在则创建
127.0.0.1:6379> HSETNX myhash field4 hello
(integer) 1
127.0.0.1:6379> HSETNX myhash field4 wordl
(integer) 0
```

## Zset(有序集合)

> 在set的基础上，增加了一个值 zset k1 score1 v1

```bash
127.0.0.1:6379> zadd k1 1 one
(integer) 1
127.0.0.1:6379> zadd k1 2 two
(integer) 1
127.0.0.1:6379> zadd k1 3 three 4 four
(integer) 2
127.0.0.1:6379> ZRANGE k1 0 -1
1) "one"
2) "two"
3) "three"
4) "four"
#####################################################################################################
#排序
127.0.0.1:6379> zadd sla 250 xh 200 zp 230 zk #新建sla集合并增加3个人的工资
(integer) 3
127.0.0.1:6379> ZRANGEBYSCORE sla -inf +inf #由小到大排序
1) "zp"
2) "zk"
3) "xh"
127.0.0.1:6379> ZRANGE sla 0 -1
1) "zp"
2) "zk"
3) "xh"
127.0.0.1:6379> ZRANGEBYSCORE sla -inf +inf withscores #排序并显示值
1) "zp"
2) "200"
3) "zk"
4) "230"
5) "xh"
6) "250"
127.0.0.1:6379> ZRANGEBYSCORE sla -inf 230 withscores #指定排序范围，显示小于230的升序排列
1) "zp"
2) "200"
3) "zk"
4) "230"
127.0.0.1:6379> ZREVRANGEBYSCORE sla +inf -inf #由大到小降序排序
1) "xh"
2) "zk"
3) "zp"
127.0.0.1:6379> ZCARD sla #获取有序集合中的个数
(integer) 2
#####################################################################################################
#zrem移除元素
127.0.0.1:6379> ZRANGE sla 0 -1
1) "zp"
2) "zk"
3) "xh"
127.0.0.1:6379> ZREM sla xh
(integer) 1
127.0.0.1:6379> ZRANGE sla 0 -1
1) "zp"
2) "zk"
#####################################################################################################
#获取指定区间的成员数量
127.0.0.1:6379> zadd k1 1 hello
(integer) 1
127.0.0.1:6379> zadd k1 2 world 3 zp
(integer) 2
127.0.0.1:6379> ZCOUNT k1 1 3
(integer) 3
```

# 三种特殊数据类型

## geospatial 地理位置

```bash
# 添加位置
# 地球两极无法添加
#一般会下载数据然后通过程序有一键导入
127.0.0.1:6379> geoadd china:city 116.40 39.90 beijing
(integer) 1
127.0.0.1:6379> geoadd china:city 121.47 31.23 shanghai
(integer) 1
127.0.0.1:6379> geoadd china:city 106.20 29.53 chongqing
(integer) 1
127.0.0.1:6379> geoadd china:city 114.05 22.52 shenzhen
(integer) 1
127.0.0.1:6379> geoadd china:city 120.16 30.24 hangzhou
(integer) 1
127.0.0.1:6379> geoadd china:city 108.96 34.26 xian
(integer) 1
#####################################################################################################
# 获取经纬度
127.0.0.1:6379> GEOPOS china:city beijing
1) 1) "116.39999896287918091"
   2) "39.90000009167092543"
127.0.0.1:6379> GEOPOS china:city shanghai
1) 1) "121.47000163793563843"
   2) "31.22999903975783553"
127.0.0.1:6379> GEOPOS china:city chongqing
1) 1) "106.19999796152114868"
   2) "29.52999957900659211"
##################################################################################################### 
# 两个定位的直线距离，指定单位KM
127.0.0.1:6379> GEODIST china:city beijing shanghai km #北京到上海的直线距离（KM）
"1067.3788"
##################################################################################################### 
# 查询以某经纬为中心的半径内的信息
127.0.0.1:6379> GEORADIUS china:city 110 30 1000 km #查询以110 30为中心1000km以内的城市
1) "chongqing"
2) "xian"
3) "shenzhen"
4) "hangzhou"
127.0.0.1:6379> GEORADIUS china:city 110 30 500 km #查询以110 30为中心500km以内的城市
1) "chongqing"
2) "xian"
#查询以110 30为中心500km以内的城市，并显示距离
127.0.0.1:6379> GEORADIUS china:city 110 30 500 km withdist 
1) 1) "chongqing"
   2) "370.5852"
2) 1) "xian"
   2) "483.8340"
#查询以110 30为中心500km以内的城市，并显示经纬度
127.0.0.1:6379> GEORADIUS china:city 110 30 500 km withcoord 
1) 1) "chongqing"
   2) 1) "106.19999796152114868"
      2) "29.52999957900659211"
2) 1) "xian"
   2) 1) "108.96000176668167114"
      2) "34.25999964418929977"
#查询以110 30为中心1000km以内的城市，并显示经纬度及距离和显示的数量，指定为3则只显示3个
127.0.0.1:6379> GEORADIUS china:city 110 30 1000 km withdist withcoord count 3
1) 1) "chongqing"
   2) "370.5852"
   3) 1) "106.19999796152114868"
      2) "29.52999957900659211"
2) 1) "xian"
   2) "483.8340"
   3) 1) "108.96000176668167114"
      2) "34.25999964418929977"
3) 1) "shenzhen"
   2) "924.6408"
   3) 1) "114.04999762773513794"
      2) "22.5200000879503861"
127.0.0.1:6379> GEORADIUS china:city 110 30 1000 km withdist withcoord count 4
1) 1) "chongqing"
   2) "370.5852"
   3) 1) "106.19999796152114868"
      2) "29.52999957900659211"
2) 1) "xian"
   2) "483.8340"
   3) 1) "108.96000176668167114"
      2) "34.25999964418929977"
3) 1) "shenzhen"
   2) "924.6408"
   3) 1) "114.04999762773513794"
      2) "22.5200000879503861"
4) 1) "hangzhou"
   2) "977.5143"
   3) 1) "120.1600000262260437"
      2) "30.2400003229490224"
##################################################################################################### 
找出位于指定元素周围的城市
找出以北京为中心1000km内的城市
127.0.0.1:6379> GEORADIUSBYMEMBER china:city beijing 1000 km
1) "beijing"
2) "xian"
找出以上海为中心400km内的城市
127.0.0.1:6379> GEORADIUSBYMEMBER china:city shanghai 400 km
1) "hangzhou"
2) "shanghai"
#####################################################################################################
将经纬度转换为11位的hash的字符串。字符串长得越接近，距离越近
127.0.0.1:6379> GEOHASH china:city beijing chongqing
1) "wx4fbxxfke0"
2) "wm5xbxu2xq0"
#####################################################################################################
移除位置信息
127.0.0.1:6379> ZRANGE china:city 0 -1 查看地图中全部的元素
1) "chongqing"
2) "xian"
3) "shenzhen"
4) "hangzhou"
5) "shanghai"
6) "beijing"
127.0.0.1:6379> ZREM china:city beijing 移除指定元素
(integer) 1
127.0.0.1:6379> ZRANGE china:city 0 -1
1) "chongqing"
2) "xian"
3) "shenzhen"
4) "hangzhou"
5) "shanghai"
```

## hyperloglog

> 优点:占用内存固定，2^64个不同元素只占用12kb内存

> 缺点：有0.81%的错误率，统计网站的用户访问量可忽略不计

> 如果允许容错，hyperloglog是首选

```bash
127.0.0.1:6379> PFADD log1 a b c d e f g h i j k #创建第一组元素
(integer) 1
127.0.0.1:6379> PFCOUNT log1 #元素数量11
(integer) 11
127.0.0.1:6379> PFadd log2 i j k l m n o p q r s #创建第二组元素，与第一组有3个重复
(integer) 1
127.0.0.1:6379> PFCOUNT log2 #元素数量11
(integer) 11
127.0.0.1:6379> PFMERGE log3 log1 log2 #合并去重（并集）两组集合至log3
OK
127.0.0.1:6379> PFCOUNT log3 #查看log3的并集元素数量为19
(integer) 19
```

## bitmaps

> 位存储
>
> 两个状态的都可以使用bitmap，非0即1

```bash
#统计一周打卡数key的0-6对应周一到周日，vlaue的0和1对应打开和未打卡

#创建bit并指定01状态
127.0.0.1:6379> SETBIT sign 0 0
(integer) 0
127.0.0.1:6379> SETBIT sign 2 0
(integer) 0
127.0.0.1:6379> SETBIT sign 3 0
(integer) 0
127.0.0.1:6379> SETBIT sign 4 1
(integer) 0
127.0.0.1:6379> SETBIT sign 5 1
(integer) 0
127.0.0.1:6379> SETBIT sign 6 0
(integer) 0

#查看某天是否打卡
127.0.0.1:6379> GETBIT sign 3 
(integer) 0
127.0.0.1:6379> GETBIT sign 5
(integer) 1

#统计未打卡数
127.0.0.1:6379> BITCOUNT sign
(integer) 2
```

# 事务

redis事务本质一组命令的集合，一个事务所有的命令都会被序列化，在事物执行过程中，会按照顺序执行。一次性、顺序性、排他性！执行一些列的命令。

redis事务没有隔离级别的概念

所有命令在事务中，并没有被直接执行，只有发起执行命令才会被执行。exec

redis单条命令是保持原子性的，但是事务不保证原子性。

redis：

​	开启事务

​	命令入队

​	执行事务

锁：redis可以实现乐观锁

## 正常执行事务

```bash

```

