##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Mon 28 Setp 2020 14:29:31 PM CST

##
#!/bin/sh
BASE=`pwd`
BUILD_HOST=arm-linux
OUTPUT_PATH=${BASE}/install/

export PATH=${PATH}:/opt/gcc-arm-linux-gnueabi/bin

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

tar_package () {
    cd ${BASE}/compressed
    ls * > /tmp/list.txt
    for TAR in `cat /tmp/list.txt`
    do
        tar -xf $TAR -C  ../source
    done
    rm -rf /tmp/list.txt
}

download_package () {
    cd ${BASE}/compressed
    #下载包
    ## http://downloads.es.net/pub/iperf/
    tget    https://downloads.es.net/pub/iperf/iperf-3.6.tar.gz
}

set_compile_env_for_arm () {
	export CC=${BUILD_HOST}-gcc
	export AR=${BUILD_HOST}-ar
	export LD=${BUILD_HOST}-ld
	export RANLIB=${BUILD_HOST}-ranlib
	export STRIP=${BUILD_HOST}-strip
}

make_iperf_host () {
    cd ${BASE}/source/*
    ./configure --prefix=${OUTPUT_PATH}/iperf_host 
    make clean
    make -j4 && make install
}

make_iperf_target () {
    cd ${BASE}/source/*
    ./configure --host=${BUILD_HOST} --prefix=${OUTPUT_PATH}/iperf_target 
    make clean
    make -j4 && make install
}

require ${BUILD_HOST}-gcc

make_dirs
download_package
tar_package
make_iperf_host
set_compile_env_for_arm
make_iperf_target
