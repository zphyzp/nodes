

```shell
#网络
docker network create --subnet 172.20.0.0/16 --ip-range 172.20.240.0/20 zabbix-net
docker network create --subnet 172.21.0.0/16 --ip-range 172.21.240.0/20 zabbix-proxy
```

```shell
#mysql
docker run --name mysql-server-5.2.6 -t \
  -e MYSQL_DATABASE="zabbix" \
  -e MYSQL_USER="zabbix" \
  -e MYSQL_PASSWORD="zabbix" \
  -e MYSQL_ROOT_PASSWORD="Capinfo@123" \
  --network=zabbix-net \
  -v /data/zabbix_data/mysql:/var/lib/mysql \
  -p 30006:3306 \
  -dit \
  mysql:8.0 \
  --character-set-server=utf8 --collation-server=utf8_bin \
  --default-authentication-plugin=mysql_native_password
  
 #proxy_mysql
 docker run --name mysql-proxy-5.2.6 -it \
-e MYSQL_DATABASE="zabbix_proxy" \
-e MYSQL_USER="zabbix_proxy" \
-e MYSQL_PASSWORD="zabbix_proxy" \
-e MYSQL_ROOT_PASSWORD="Capinfo@123" \
-v /data/zabbix_data/mysql_proxy:/var/lib/mysql \
-p 30007:3306 \
--network zabbix-proxy \
--restart unless-stopped \
-d mysql:8.0 \
--character-set-server=utf8 --collation-server=utf8_bin

```

```shell
#server
docker run --name zabbix-server-5.2.6 -t \
      -e DB_SERVER_HOST="mysql-server-5.2.6" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix" \
      -e MYSQL_ROOT_PASSWORD="Capinfo@123" \
      -e ZBX_JAVAGATEWAY="zabbix-java-5.2.6" \
      --network=zabbix-net \
      -p 10051:10051 \
      -v /etc/localtime:/etc/localtime:ro \
      --restart unless-stopped \
      -d hub.jgswy.com/zabbix/zabbix-server-5.2.6:v1
```

```shell
#web
docker run --name zabbix-web-5.2.6 -t \
      -e ZBX_SERVER_HOST="zabbix-server-5.2.6" \
      -e DB_SERVER_HOST="mysql-server-5.2.6" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix" \
      -e MYSQL_ROOT_PASSWORD="Capinfo@123" \
      --network=zabbix-net \
      -v /data/zabbix_data/web:/usr/share/zabbix \
      -p 85:8080 \
      --restart unless-stopped \
      -d hub.jgswy.com/zabbix/zabbix-web-5.2.6:v1


```

```shell
#java-gateway
docker run --name zabbix-java-5.2.6 -t \
      --network=zabbix-net \
      --restart unless-stopped \
      -d hub.jgswy.com/zabbix/zabbix-java-5.2.6:v1
```

```shell
#proxy
docker run --name zabbix-proxy-5.2.6 \
-e DB_SERVER_HOST="mysql-proxy-5.2.6" \
-e MYSQL_DATABASE="zabbix_proxy" \
-e MYSQL_USER="zabbix_proxy" \
-e MYSQL_PASSWORD="zabbix_proxy" \
-e ZBX_HOSTNAME="Zabbix-Proxy01" \
-e ZBX_SERVER_HOST=192.66.32.25 \
-e ZBX_CACHESIZE=256M \
-e ZBX_CONFIGFREQUENCY=60 \
-p 10052:10051 \
--network zabbix-proxy \
--restart unless-stopped \
-v /etc/localtime:/etc/localtime:ro \
-d hub.jgswy.com/zabbix/zabbix-proxy-5.2.6:v1
```

```shell
#修改zabbix图形时间
/etc/php7/php-fpm.d/zabbix.conf  
php_value[date.timezone] = ${PHP_TZ}
修改为 
php_value[date.timezone] = Asia/Shanghai
```

