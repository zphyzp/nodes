#!/usr/bin/expect -f
set date [exec date "+%Y%m%d"]
set password Wabjtam@4411
spawn scp /var/log/check/1.163-Check-bjgtjnew.web3-$date.txt root@192.168.1.44:/var/log/check/1.163-Check-bjgtjnew.web3-$date.txt 
set timeout 300
expect "root@192.168.1.44's password:"
set timeout 300
send "$password\r"
set timeout 300
send "exit\r"
expect eof
