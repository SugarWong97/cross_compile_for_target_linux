#
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#
#    File Name:  make.sh
#    Created  :  2020-10-17 09:38:39
#
#
#!/bin/sh

source ../.common

download_package () {
    cd ${BASE}/compressed
    #下载包
    tget https://launchpadlibrarian.net/70776071/i2c-tools_3.0.3.orig.tar.bz2
}

make_taget () {
    cd ${BASE}/source/i2c-tools_3*
    mkdir -p ${OUTPUT_PATH}/i2c-tools
    CC=${_CC} LD=${_LD} make
    make install prefix=${OUTPUT_PATH}/i2c-tools
}

function make_build ()
{
    download_package  || return 1
    tar_package  || return 1
    make_taget  || return 1
}

make_build || echo "Err"
