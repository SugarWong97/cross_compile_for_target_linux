##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Mon 28 Setp 2020 14:29:31 PM CST

##
#!/bin/sh

source ../.common

download_package () {
    cd ${BASE}/compressed
    #下载包
    ## http://downloads.es.net/pub/iperf/
    tget    https://downloads.es.net/pub/iperf/iperf-3.6.tar.gz
}

set_compile_env_for_arm () {
	export CC=${_CC}
	export AR=${_AR}
	export LD=${_LD}
	export RANLIB=${_RANLIB}
	export STRIP=${_STRIP}
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

function make_build ()
{
    download_package  || return 1
    tar_package || return 1

    make_iperf_host  || return 1
    set_compile_env_for_arm
    make_iperf_target  || return 1
}

make_build || echo "Err"
