ETHTOOL=ethtool
CONFIG_ETHTOOL_VERSION=6.0
export ETHTOOL_OUTPUT_PATH=${OUTPUT_PATH}/ethtool

download_ethtool () {
    #get_libmnl TODO : 等到libmnl被更多的库使用后，再为其搞一个单独的目录
    download_libmnl
    tget https://mirrors.edge.kernel.org/pub/software/network/ethtool/ethtool-${CONFIG_ETHTOOL_VERSION}.tar.xz
}

mk_ethtool () {

    cd $CODE_PATH/ethtool-${CONFIG_ETHTOOL_VERSION}

    ./configure  --host=arm-linux CC=${_CC} \
        MNL_CFLAGS="-I${LIBMNL_INSTALL}/include" MNL_LIBS="-L${LIBMNL_INSTALL}/lib -lmnl" \
        --prefix=${ETHTOOL_OUTPUT_PATH} \
        LDFLAGS=-static

    make CC=${_CC} prefix=${LRZSZ_INSTALL}  LIBS="" || return -1

    make install
}

echo_ethtool_help ()
{
    cat <<EOF
ethtool ethX      // 查询ethx网口基本设置，其中 x 是对应网卡的编号，如eth0、eth1等等

ethtool –h        // 显示ethtool的命令帮助(help)
ethtool –i ethX   // 查询ethX网口的相关信息
ethtool –d ethX   // 查询ethX网口注册性信息
ethtool –r ethX   // 重置ethX网口到自适应模式
ethtool –S ethX   // 查询ethX网口收发包统计

// 设置网口速率10/100/1000M、设置网口半/全双工、设置网口是否自协商
ethtool –s ethX [speed 10|100|1000] [duplex half|full]  [autoneg on|off]
EOF
}

function make_ethtool ()
{
    download_ethtool  || return 1
    tar_package || return 1

    mk_libmnl || return 1
    mk_ethtool  || return 1
    echo_ethtool_help
}
