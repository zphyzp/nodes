#!/bin/bash
logs_path="/data/nginx/log/"
pid_path="/data/nginx/log/nginx.pid"
mv ${logs_path}error.log ${logs_path}error_$(date -d "yesterday" +"%Y%m%d").log
kill -USR1 `cat ${pid_path}`


log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent" "$http_x_forwarded_for"';

map $time_iso8601 $logdate {
    '~^(?<ymd>\d{4}-\d{2}-\d{2})' $ymd;
    default                       'date-not-found';
}

access_log  log/access-$logdate.log main;
open_log_file_cache max=10;