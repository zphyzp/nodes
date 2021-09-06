# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

# Check release
if [ -f /etc/redhat-release ]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
fi


# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
SKYBLUE='\033[0;36m'
PLAIN='\033[0m'

rm -rf /tmp/report && mkdir /tmp/report

echo "���ڰ�װ��Ҫ�������������ĵȴ�..."



# Install Virt-what
if  [ ! -e '/usr/sbin/virt-what' ]; then
    echo "Installing Virt-What......"
    if [ "${release}" == "centos" ]; then
        yum -y install virt-what > /dev/null 2>&1
    else
        apt-get update
        apt-get -y install virt-what > /dev/null 2>&1
    fi
fi

# Install uuid
echo "Installing uuid......"
if [ "${release}" == "centos" ]; then
    yum -y install uuid > /dev/null 2>&1
else
    apt-get -y install uuid > /dev/null 2>&1
fi


# Install curl
echo "Installing curl......"
if [ "${release}" == "centos" ]; then
    yum -y install curl > /dev/null 2>&1
else
    apt-get -y install curl > /dev/null 2>&1
fi

# Check Python
if  [ ! -e '/usr/bin/python' ]; then
    echo "Installing Python......"
    if [ "${release}" == "centos" ]; then
            yum update > /dev/null 2>&1
            yum -y install python
        else
            apt-get update > /dev/null 2>&1
            apt-get -y install python
    fi
fi

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

next() {
    printf "%-74s\n" "-" | sed 's/\s/-/g'
}

io_test() {
    (LANG=C dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}
calc_disk() {
    local total_size=0
    local array=$@
    for size in ${array[@]}
    do
        [ "${size}" == "0" ] && size_t=0 || size_t=`echo ${size:0:${#size}-1}`
        [ "`echo ${size:(-1)}`" == "K" ] && size=0
        [ "`echo ${size:(-1)}`" == "M" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' / 1024}' )
        [ "`echo ${size:(-1)}`" == "T" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' * 1024}' )
        [ "`echo ${size:(-1)}`" == "G" ] && size=${size_t}
        total_size=$( awk 'BEGIN{printf "%.1f", '$total_size' + '$size'}' )
    done
    echo ${total_size}
}
cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
tram=$( free -m | awk '/Mem/ {print $2}' )
uram=$( free -m | awk '/Mem/ {print $3}' )
swap=$( free -m | awk '/Swap/ {print $2}' )
uswap=$( free -m | awk '/Swap/ {print $3}' )
up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime )
load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
opsy=$( get_opsy )
arch=$( uname -m )
lbit=$( getconf LONG_BIT )
kern=$( uname -r )
ipv6=$( wget -qO- -t1 -T2 ipv6.icanhazip.com )
disk_size1=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $2}' ))
disk_size2=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $3}' ))
disk_total_size=$( calc_disk ${disk_size1[@]} )
disk_used_size=$( calc_disk ${disk_size2[@]} )
clear
next
echo -e "CPU �ͺ�             : ${SKYBLUE}$cname${PLAIN}"
echo -e "CPU ������           : ${SKYBLUE}$cores${PLAIN}"
echo -e "CPU Ƶ��             : ${SKYBLUE}$freq MHz${PLAIN}"
echo -e "��Ӳ�̴�С           : ${SKYBLUE}$disk_total_size GB ($disk_used_size GB Used)${PLAIN}"
echo -e "���ڴ��С           : ${SKYBLUE}$tram MB ($uram MB Used)${PLAIN}"
echo -e "SWAP��С             : ${SKYBLUE}$swap MB ($uswap MB Used)${PLAIN}"
echo -e "����ʱ��             : ${SKYBLUE}$up${PLAIN}"
echo -e "ϵͳ����             : ${SKYBLUE}$load${PLAIN}"
echo -e "ϵͳ                 : ${SKYBLUE}$opsy${PLAIN}"
echo -e "�ܹ�                 : ${SKYBLUE}$arch ($lbit Bit)${PLAIN}"
echo -e "�ں�                 : ${SKYBLUE}$kern${PLAIN}"
echo -ne "���⻯ƽ̨           : "
virtua=$(virt-what) 2>/dev/null
if [[ ${virtua} ]]; then
    echo -e "${SKYBLUE}$virtua${PLAIN}"
else
    echo -e "${SKYBLUE}No Virt${PLAIN}"
fi
next
io1=$( io_test )
echo -e "Ӳ��I/O (��һ�β���) : ${YELLOW}$io1${PLAIN}"
io2=$( io_test )
echo -e "Ӳ��I/O (�ڶ��β���) : ${YELLOW}$io2${PLAIN}"
io3=$( io_test )
echo -e "Ӳ��I/O (�����β���) : ${YELLOW}$io3${PLAIN}"
next
##Record All Test data
rm -rf /tmp/info.txt
touch /tmp/info.txt
echo $cname >> /tmp/info.txt
echo $cores >> /tmp/info.txt
echo $freq MHz >> /tmp/info.txt
echo "$disk_total_size GB ($disk_used_size GB ��ʹ��) ">> /tmp/info.txt
echo "$tram MB ($uram MB ��ʹ��) ">> /tmp/info.txt
echo "$swap MB ($uswap MB ��ʹ��)" >> /tmp/info.txt
echo $up >> /tmp/info.txt
echo $load >> /tmp/info.txt
echo $opsy >> /tmp/info.txt
echo "$arch ($lbit λ) ">> /tmp/info.txt
echo $kern >> /tmp/info.txt
echo $virtua >> /tmp/info.txt
echo $io1 >> /tmp/info.txt
echo $io2 >> /tmp/info.txt
echo $io3 >> /tmp/info.txt
AKEY=$( uuid )




