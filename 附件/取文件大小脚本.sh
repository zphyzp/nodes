time=$(date "+%Y%m%d")
if [ ! -f "/var/log/apaclog/"$time"apac.log" ];then
  touch /var/log/apaclog/"$time"apac.log
else
  echo file exist >/dev/null
fi

ls -lh /data/apache-2.4.39/logs/sj/*$time.log | awk '{printf "%-8s%-10s%-40s\n",$5,$8,$9}' >>/var/log/apaclog/"$time"apac.log


