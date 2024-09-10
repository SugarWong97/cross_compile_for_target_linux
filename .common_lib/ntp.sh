
export NTP=ntp
export CONFIG_NTP_VERSION=4.2.8p17
export NTP_VERSION=${NTP}-${CONFIG_NTP_VERSION}

#export CONFIG_NTP_SERVER_IP
#export CONFIG_NTP_OTHER_SERVER_IP
#export CONFIG_NTP_SERVER_DRIFTFILE
#export CONFIG_NTP_SERVER_PIDFILE
#export CONFIG_NTP_SERVER_LOGFILE

export CONFIG_NTP_SERVER_IP_DEFAULT="192.168.1.1"
export CONFIG_NTP_OTHER_SERVER_IP_DEFAULT="192.168.1.2"
export CONFIG_NTP_SERVER_DRIFTFILE_DEFAULT="/var/ntp/drift"
export CONFIG_NTP_SERVER_PIDFILE_DEFAULT="/var/run/ntpd.pid"
export CONFIG_NTP_SERVER_LOGFILE_DEFAULT="/var/log/ntp.log"

NTP_OUTPUT=${OUTPUT_PATH}/${NTP}

#下载包
download_ntp () {
    get_ssl
    #echo "https://downloads.nwtime.org/ntp/"

    # e.g :
    ##  https://downloads.nwtime.org/ntp/4.2.8/ntp-4.2.8p17.tar.gz
    ##  4.2.8p17 -> 4.2.8
    config_ntp_version_for_url=`echo $CONFIG_NTP_VERSION| cut -f 1 -d "p" `

    tget  https://downloads.nwtime.org/ntp/${config_ntp_version_for_url}/${NTP_VERSION}.tar.gz
}


mk_ntp () {
    clear
    clear
    clear
    clear
(
    cat <<EOF
    cd ${CODE_PATH}/*${NTP_VERSION}*
    export LD=${_LD}
    export CC=${_CC}
    # 自行替换 openssl 的路径
    ./configure --host=${BUILD_HOST} --target=arm-linux \
        --prefix=${NTP_OUTPUT}  \
    --disable-shared --with-yielding-select=no \
    --with-openssl-libdir=${OUTPUT_PATH}/${OPENSSL}/lib \
    --with-openssl-incdir=${OUTPUT_PATH}/${OPENSSL}/include \
    CFLAGS="-O2 -g -fPIC"
    #--without-sntp --with-ntpsnmpd=no

    make $MKTHD LD=${_LD} CC=${_CC} || exit
    make install
EOF
) > .build.ntp.sh

    bash `pwd`/.build.ntp.sh
}

gen_ntp_client_usage()
{
(
    cat<<EOF
# 修改时区(可选, 嵌入式设备应该将此行写入 /etc/profile 中)
export TZ="UTC-08:00"

# 同步时间服务器的时间
killall ntpdate > /dev/null 2>&1 && sleep 1
./bin/ntpdate   $CONFIG_NTP_SERVER_IP
#./bin/ntpdate   time.buptnet.edu.cn

# 显示时间
date

# 显示UTC时间
date -u

# 保存时间到本地（如果有硬件RTC）
hwclock -w
EOF
)   > ${NTP_OUTPUT}/client.sh
    chmod + x ${NTP_OUTPUT}/client.sh

(
    cat<<EOF
while true
do
    ./client.sh
    echo "Waiting 600s for next update"
    sleep 600
done
EOF
)   > ${NTP_OUTPUT}/client_loop.sh
    chmod + x ${NTP_OUTPUT}/client_loop.sh

}

gen_ntp_server_usage()
{
    network_ip=`echo ${CONFIG_NTP_SERVER_IP%.*}.0`

(
    cat<<EOF
#配置：为同网络的其他设备提供NTP服务，无上级NTP-Server连接
## 注意：ntp服务器开启后五到十几分钟才能在客户端系统中执行以下命令，
## 否则时间同步会失败，提示'no server suitable for synchronization found'

# 指定时间漂移记录文件
# 作用：如果ntpd停止并重新启动，它将从该文件初始化频率，并避免可能的长时间间隔重新学习校正。
driftfile ${CONFIG_NTP_SERVER_DRIFTFILE}

pidfile   ${CONFIG_NTP_SERVER_PIDFILE}
logfile   ${CONFIG_NTP_SERVER_LOGFILE}

### 拒绝所有来源的任何访问(未启用)
## restrict default kod nomodify notrap nopeer noquery
## restrict -6 default kod nomodify notrap nopeer noquery

# 开放本机的任何访问
restrict 127.0.0.1
restrict -6 ::1

# 允许 ${network_ip}/24 网段主机进行时间同步
restrict ${network_ip} mask 255.255.255.0 nomodify notrap

# 允许以本地时间作为时间服务
server   127.127.1.0 # local clock
# 本地时间的精准度等级
fudge    127.127.1.0 stratum 5


### 允许上层时间服务器主动修改本机时间(目前未成功)
## restrict $CONFIG_NTP_OTHER_SERVER_IP nomodify notrap noquery
## server   $CONFIG_NTP_OTHER_SERVER_IP prefer iburst minpoll 4 maxpoll 10


# 广播延迟
broadcastdelay 0.008
# 配置key
keys /etc/ntp/keys

### 引入指定目录下的配置
## includefile /etc/ntp/crypto/pw
EOF
)   > ${NTP_OUTPUT}/ntpd.conf


(
    cat<<EOF
# 创建有关文件
## Drift 文件
mkdir -p \`dirname  $CONFIG_NTP_SERVER_DRIFTFILE\`
touch    $CONFIG_NTP_SERVER_DRIFTFILE
## PID 文件
mkdir -p \`dirname  $CONFIG_NTP_SERVER_PIDFILE\`
touch    $CONFIG_NTP_SERVER_PIDFILE
## LOG 文件
mkdir -p \`dirname  $CONFIG_NTP_SERVER_LOGFILE\`
touch    $CONFIG_NTP_SERVER_LOGFILE

# 启动server
./bin/ntpd -c ntpd.conf
sleep 2; cat $CONFIG_NTP_SERVER_LOGFILE
EOF
)   > ${NTP_OUTPUT}/server.sh
    chmod + x ${NTP_OUTPUT}/server.sh

}

make_ntp ()
{
    if [ -z "$CONFIG_NTP_SERVER_IP" ];then
        export CONFIG_NTP_SERVER_IP="$CONFIG_NTP_SERVER_IP_DEFAULT"
    fi
    if [ -z "$CONFIG_NTP_OTHER_SERVER_IP" ];then
        export CONFIG_NTP_OTHER_SERVER_IP="$CONFIG_NTP_OTHER_SERVER_IP_DEFAULT"
    fi
    if [ -z "$CONFIG_NTP_SERVER_DRIFTFILE" ];then
        export CONFIG_NTP_SERVER_DRIFTFILE="$CONFIG_NTP_SERVER_DRIFTFILE_DEFAULT"
    fi

    if [ -z "$CONFIG_NTP_SERVER_PIDFILE" ];then
        export CONFIG_NTP_SERVER_PIDFILE="$CONFIG_NTP_SERVER_PIDFILE_DEFAULT"
    fi
    if [ -z "$CONFIG_NTP_SERVER_LOGFILE" ];then
        export CONFIG_NTP_SERVER_LOGFILE="$CONFIG_NTP_SERVER_LOGFILE_DEFAULT"
    fi

    download_ntp
    tar_package
    make_ssl  || { echo >&2 "make_ssl "; exit 1; }
    mk_ntp  || { echo >&2 "mk_ntp "; exit 1; }
    gen_ntp_client_usage
    gen_ntp_server_usage
}

