#
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#
#    File Name:  make.sh
#    Created  :  2020-10-17 09:38:39
#
#
#!/bin/sh

BASE=`pwd`
OUTPUT_PATH=${BASE}/install/

## 填写你的工具链名称
BUILD_HOST=arm-linux
## 必要时，填写你的工具链的所在路径
BUILD_HOST_PATH=/opt/gcc-arm-linux-gnueabi/bin

export PATH=${PATH}:${BUILD_HOST_PATH}

require () {
    if [ -z "$1" ];then
        return 
    fi
    command -v $1 >/dev/null 2>&1 || { echo >&2 "Aborted : Require \"$1\" but not found."; exit 1;   }
    echo "Using: $1"
}

make_dirs() {
    cd ${BASE}
    mkdir  compressed  install  source -p
}

tget () { #try wget
    filename=`basename $1`
    echo "Downloading [${filename}]..."
    if [ ! -f ${filename} ];then
        wget $1
    fi

    echo "[OK] Downloaded [${filename}] "
}

download_package () {
    cd ${BASE}/compressed
    #下载包
    tget https://launchpadlibrarian.net/70776071/i2c-tools_3.0.3.orig.tar.bz2
}

tar_package () {
    cd ${BASE}/compressed
    ls * > /tmp/list.txt
    for TAR in `cat /tmp/list.txt`
    do
        tar -xf $TAR -C  ../source
    done
    rm -rf /tmp/list.txt
}

make_taget () {
    cd ${BASE}/source/*
    mkdir -p ${OUTPUT_PATH}/i2c-tools_arm
    CC=${BUILD_HOST}-gcc LD=${BUILD_HOST}-ld make
    make install prefix=${OUTPUT_PATH}/i2c-tools_arm
}

require ${BUILD_HOST}-gcc

make_dirs
tar_package
make_taget
exit $?
