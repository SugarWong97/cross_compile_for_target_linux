##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#
#    File Name:  make.sh
#    Created  :  2020-07-31 09:38:39
#
##
#!/bin/sh

source ../.common

# 最终的运行环境
FIN_INSTALL=/usr/local/lighttpd

download_package () {
    cd ${BASE}/compressed
    #下载包
    tget https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.55.tar.gz
}

function make_taget  () {
function _make_sh () {
cat<<EOF
    ./configure --disable-ipv6 \
    --disable-lfs  --without-bzip2 \
    --without-zlib \
    --without-pcre \
    --without-openssl \
    --host=${BUILD_HOST} \
    --prefix=${FIN_INSTALL}
EOF
}
    cd ${BASE}/source/*

    _make_sh > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make $MKTHD
}

make_install () {
    mkdir ${BASE}/install/lib  -p
    mkdir ${BASE}/install/sbin -p
    cd ${BASE}/source/*
    SRCTOP=`pwd`
    echo "${FIN_INSTALL} with ${BUILD_HOST}gcc" > ${BASE}/install/ccinfo
    cp $SRCTOP/src/.libs/*.so       ${OUTPUT_PATH}/lib  -r
    cp $SRCTOP/src/lighttpd-angel   ${OUTPUT_PATH}/sbin
    cp $SRCTOP/src/lighttpd         ${OUTPUT_PATH}/sbin
    cp $SRCTOP/doc/config  -r       ${OUTPUT_PATH}
    rm  ${OUTPUT_PATH}/config/Make*
}

function make_build ()
{
    download_package  || return 1
    tar_package || return 1
    make_taget && make_install
}

make_build || echo "Err"
