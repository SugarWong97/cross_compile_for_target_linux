##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Fri 22 Nov 2019 11:49:30 AM CST

##
#!/bin/sh

source ../.common

LIBMNL=1.0.5
LIBMNL_INSTALL=${OUTPUT_PATH}/libmnl

ETHTOOL=6.0
ETHTOOL_INSTALL=${OUTPUT_PATH}/ethtool

download_package () {
    cd ${BASE}/compressed
    #tget https://www.netfilter.org/pub/libmnl/libmnl-1.0.0.tar.bz2
    tget https://www.netfilter.org/pub/libmnl/libmnl-${LIBMNL}.tar.bz2
    tget https://mirrors.edge.kernel.org/pub/software/network/ethtool/ethtool-${ETHTOOL}.tar.xz
    #tget https://github.com/thkukuk/libnsl/releases/download/v${LIBNSL}/libnsl-${LIBNSL}.tar.xz
}

make_libmnl () {
    cd $CODE_PATH/libmnl-${LIBMNL}

    ./configure --host=${BUILD_HOST} --prefix=${LIBMNL_INSTALL} \
        --enable-static --disable-shared

    make CC=${_CC} prefix=${LIBMNL_INSTALL} || return -1

    make install prefix=${LIBMNL_INSTALL}

}

make_ethtool () {

    cd $CODE_PATH/ethtool-${ETHTOOL}

    ./configure  --host=arm-linux CC=${_CC} \
        MNL_CFLAGS="-I${LIBMNL_INSTALL}/include" MNL_LIBS="-L${LIBMNL_INSTALL}/lib -lmnl" \
        --prefix=${ETHTOOL_INSTALL} \
        LDFLAGS=-static

    make CC=${_CC} prefix=${LRZSZ_INSTALL}  LIBS="" || return -1

    make install
}

echo_help ()
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

function make_build ()
{
    download_package  || return 1
    tar_package || return 1

    make_libmnl || return 1
    make_ethtool  || return 1
    echo_help
}

make_build || echo "Err"
