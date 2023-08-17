# 是否需要SSL支持，需要选择yes，否则no
export IPERF_SUPPORT_SSL="no"

IPERF=3.6

download_iperf () {
    if [ "$IPERF_SUPPORT_SSL" = "yes" ]; then
        get_zlib
        get_ssl
    fi
    ## http://downloads.es.net/pub/iperf/
    tget    https://downloads.es.net/pub/iperf/iperf-${IPERF}.tar.gz
}

mk_iperf_host () {
    bash <<EEOF
    cd ${BASE}/source/iperf-${IPERF}
    ./configure --prefix=${OUTPUT_PATH}/iperf_host
    make clean
    make $MKTHD && make install
EEOF
}

mk_iperf_target () {
    CONFIG_SSL=""
    if [ "$IPERF_SUPPORT_SSL" = "yes" ]; then
        make_zlib
        make_ssl
        CONFIG_SSL="--with-openssl=${OUTPUT_PATH}/${OPENSSL}"
    else
        CONFIG_SSL="--with-openssl=no"
    fi
        bash <<EOF
        cd ${BASE}/source/iperf-${IPERF}
        ./configure --host=${BUILD_HOST} --prefix=${OUTPUT_PATH}/iperf_target ${CONFIG_SSL}
        make clean
        make $MKTHD && make install
EOF

}

echo_iperf_help ()
{
    cat <<EEOF
==================================

# 启动服务端 (指定端口为 520)

iperf3 -s -B 0.0.0.0 -p 520

  -s 表示以服务器方式启动 iperf
  -B 表示监听指定 IP地址，0.0.0.0 表示所有网卡的IP地址
  -p 表示监听指定 端口，上述我们指定监听的端口号是 520，该参数可有可无，没有该参数时，默认坚挺的端口号是 5201


# 客户端 连接，开始测试 (测试192.168.1.123设备，520端口，以UDP传输，测试1G带宽，并在测试的10秒中，每秒打印一次结果)

iperf3 -c 192.168.1.123 -b 1g -t 10 -i 1 -u -p 520  --forceflush

  -c 表示以客户端方式启动 iperf，使用 iPerf 服务器IP 192.168.3.83 进行测试
  -b 表示估计带宽，就是最高能跑多少，1g 表示估计能跑 1Gbps
  -t 表示持续测试时间(秒)，10 表示测试 10s
  -i 表示多少秒输出一次测试结果，1 表示 1s 刷新一次
  -u 表示用 udp 连接来测速，默认是 tcp 连接测试，因为 tcp 要进行确认，所以不如 udp 测试的准确
  -p 表示测试服务器端口，520 表示测速服务器的端口是 520
  --forceflush 表示打印时强制写入缓冲区，以解决类似输出重定向时无法读取实时结果的问题
EEOF
}

function make_iperf ()
{
    download_iperf  || return 1
    tar_package || return 1


    # 为了方便远程测试，提供宿主机版本的iperf
    mk_iperf_host  || return 1
    # 为嵌入式设备准备的iperf
    mk_iperf_target  || return 1

    # 输出提示
    echo_iperf_help
}
