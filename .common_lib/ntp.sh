
export NTP=ntp
export CONFIG_NTP_VERSION=4.2.8p17
export NTP_VERSION=${NTP}-${CONFIG_NTP_VERSION}

NTP_OUTPUT=${OUTPUT_PATH}/${NTP}

#下载包
download_ntp () {
    get_ssl
    #echo "https://downloads.nwtime.org/ntp/"

    # 4.2.8p17 -> 4.2.8
    # e.g :
    ##  https://downloads.nwtime.org/ntp/4.2.8/ntp-4.2.8p17.tar.gz
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
1. 修改时区(可选)
  export TZ="UTC-08:00"

2. 同步时间服务器的时间
  ./bin/ntpdate   target-ip
  例如 ：
    ./bin/ntpdate   time.buptnet.edu.cn

3. 显示UTC时间可以使用命令
    date -u

4. 保存时间到本地（如果有硬件RTC）
    hwclock b-w
EOF
)   > ${NTP_OUTPUT}/client.txt
}

gen_ntp_server_usage()
{
    driftfile="/var/ntp/drift"
    server_ip="192.168.1.1"


(
    cat<<EOF
# 注意
# ntp服务器开启后五到十几分钟才能在客户端系统中执行以下命令，否则时间同步会失败

# 指定时间漂移记录文件，
# 作用：如果ntpd停止并重新启动，它将从该文件初始化频率，并避免可能的长时间间隔重新学习校正。
driftfile ${driftfile}

##下面两行默认是拒绝所有来源的任何访问
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery

#开放本机的任何访问
restrict 127.0.0.1
restrict -6 ::1

# 允许内网其他机器同步时间(允许192.168.1.0/24 网段主机进行时间同步)
restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap

#指定ntp服务器地址
server $server_ip

#允许上层时间服务器主动修改本机时间
restrict $server_ip nomodify notrap noquery

#外部时间服务器不可用时，以本地时间作为时间服务
server  127.127.1.0
fudge   127.127.1.0 stratum 10

##下面两行为配置文件默认开启
includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys


EOF
)   > ${NTP_OUTPUT}/server.ntp.conf

(
    cat<<EOF
启动server
./bin/ntpd-c server.ntp.conf  # -p /tmp/ntpd.pid
EOF
)   > ${NTP_OUTPUT}/server.txt

}

make_ntp ()
{
    download_ntp
    tar_package
    make_ssl  || { echo >&2 "make_ssl "; exit 1; }
    mk_ntp  || { echo >&2 "mk_ntp "; exit 1; }
    gen_ntp_client_usage
    gen_ntp_server_usage
}

