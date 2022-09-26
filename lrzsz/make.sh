##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Fri 22 Nov 2019 11:49:30 AM CST

##
#!/bin/sh

source ../.common

LRZSZ=0.12.20
LRZSZ_INSTALL=${OUTPUT_PATH}/lrzsz

LIBNSL=2.0.0
LIBNSL_INSTALL=${OUTPUT_PATH}/libnsl

download_package () {
    cd ${BASE}/compressed
    tget https://ohse.de/uwe/releases/lrzsz-${LRZSZ}.tar.gz
    #tget https://github.com/thkukuk/libnsl/releases/download/v${LIBNSL}/libnsl-${LIBNSL}.tar.xz
}

make_nsl () {
    cd $CODE_PATH/libnsl-${LIBNSL}

    ./configure --host=${BUILD_HOST} --prefix=${LIBNSL_INSTALL} \
        --disable-nsl \
        --enable-static --disable-shared

    make CC=${_CC} prefix=${LIBNSL_INSTALL} || return -1

    make install

}

make_lrzsz () {

    cd $CODE_PATH/lrzsz-${LRZSZ}

    ./configure --host=${BUILD_HOST} --prefix=${LRZSZ_INSTALL} --disable-nls LIBS=""

    make CC=${_CC} prefix=${LRZSZ_INSTALL}  LIBS="" || return -1

    make install
}

function make_build ()
{
    download_package  || return 1
    tar_package || return 1

    #make_nsl || return 1
    make_lrzsz  || return 1
}

make_build || echo "Err"
