#!/bin/bash
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  2023-08-16 16:44:20 PM CST

##

source ../.common

LIBMODBUS_VERSION=3.1.4

export LIBMODBUS=libmodbus
OUTPUT=${OUTPUT_PATH}/${LIBMODBUS}

function download_libmodbus () {
    # https://github.com/stephane/libmodbus/releases/tag/v3.1.10
    tget   http://libmodbus.org/releases/libmodbus-${LIBMODBUS_VERSION}.tar.gz
}

function mk_libmodbus () {
    libmodbus_dir=${CODE_PATH}/libmodbus-${1}*
    cd $libmodbus_dir;
    ./configure --prefix=${OUTPUT} --host=arm-linux --enable-static ac_cv_func_malloc_0_nonnull=yes CC=${BUILD_HOST_}gcc
    make clean;
    make CROSS_COMPILE=${BUILD_HOST_} prefix=${OUTPUT}
    make install
}

function make_libmodbus ()
{
    download_libmodbus  || return 1
    tar_package || return 1

    mk_libmodbus $LIBMODBUS_VERSION
}

make_libmodbus
