```shell
#!/bin/bash

/usr/local/freetds/bin/tsql -S $1 -U $2 -P $3 > $1.log<<EOF
select state_desc from sys.databases where name='icms_v3_fzx'
go
exit
EOF

cat $1.log|grep -w ONLINE
rm -f $1.log




[db88]
        host = 10.11.2.88
        port = 1433
        tds version = 8.0
        client chaeset = UTF-8
        instance = instance01
```

