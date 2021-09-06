#!/usr/local/bin/expect -f
set date [exec date "+%Y%m%d"]
set password Wabjtam@4405
spawn scp /var/log/check/1.111-Check-localhost.localdomain-$date.txt root@192.168.1.44:/var/log/check/1.111-Check-localhost.localdomain-$date.txt 
set timeout 300
expect "root@192.168.1.44's password:"
set timeout 300
send "$password\r"
set timeout 300
send "exit\r"
expect eof


30 07 * * * /script/check05.sh >/dev/null 2>&1
31 07 * * * /script/scpcheck.sh >/dev/null 2>&1
30 16 * * * /script/check05.sh >/dev/null 2>&1
31 16 * * * /script/scpcheck.sh >/dev/null 2>&1

spawn scp /var/log/check/1.111-Check-localhost.localdomain-20190506.txt root@192.168.1.44:/var/log/check/1.111-Check-localhost.localdomain-20190506.txt 



