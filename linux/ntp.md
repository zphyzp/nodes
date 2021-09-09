ntp服务器端配置文件

```bash
driftfile /var/lib/ntp/drift
restrict 10.254.253.0 mask 255.255.255.0 nomodify notrap
restrict 127.0.0.1
restrict ::1
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst
server 3.centos.pool.ntp.org iburst
server 127.127.1.0 # local clock
fudge 127.127.1.0 stratum 10
includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
disable monitor
```

ntp客户端配置文件

```bash
driftfile /var/lib/ntp/drift
restrict default nomodify notrap nopeer noquery
restrict 10.253.254.121 nomodify notrap nopeer noquery
restrict 127.0.0.1 
restrict ::1
restrict 10.253.254.254 mask 255.255.255.0 nomodify notrap 
server 10.254.253.53
Fudge 10.254.253.53 stratum 10
includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
disable monitor
```

