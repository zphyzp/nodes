password=Taiji1@3456
path=$1
topath=$2

while read -r ipline
do
for line in $(ls ${path})
do
expect<<-END
spawn scp ${path}${line} root@${ipline}:${topath}
expect {
 "(yes/no)?" {send "yes\r"; exp_continue}
 "${ipline}'s password:" {send "${password}\r"}
 "Permission denied" { send_user "[exec echo "\nError: Password is wrong\n"]"; exit}
}
expect eof
exit
END
done
done < ipfile.txt

