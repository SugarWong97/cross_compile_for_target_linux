#!/bin/bash
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  2023-08-14 16:29:30 PM CST

##

source ../.common

LINUXPTP_VERSION=3.1 # or 4.0
LINUXPTP_VERSION=4.0

export LINUXPTP=linuxptp
OUTPUT=${OUTPUT_PATH}/${LINUXPTP}

function download_linuxptp_v3_1 () {
    tget_and_rename   https://sourceforge.net/projects/linuxptp/files/v3.1/linuxptp-3.1.1.tgz/download linuxptp-3.1.1.tgz
}

function download_linuxptp_v4_0 () {
    tget_and_rename   https://sourceforge.net/projects/linuxptp/files/v4.0/linuxptp-4.0.tgz/download   linuxptp-4.0.tgz
}

function mk_linuxptp () {
    ptp_dir=${CODE_PATH}/linuxptp-${1}*
    make -C $ptp_dir clean;
    make -C $ptp_dir CROSS_COMPILE=${BUILD_HOST_} prefix=${OUTPUT}/for_target install
    make -C $ptp_dir clean;
    make -C $ptp_dir prefix=${OUTPUT}/for_host install
}

function make_linuxptp_v3_1 ()
{
    download_linuxptp_v3_1  || return 1
    tar_package || return 1

    mk_linuxptp 3
}

function make_linuxptp_v4_0 ()
{
    download_linuxptp_v4_0  || return 1
    tar_package || return 1

    mk_linuxptp 4
}

if [ "$LINUXPTP_VERSION" = "3.1" ];then
    make_linuxptp_v3_1 || echo "Failed!"
fi
if [ "$LINUXPTP_VERSION" = "4.0" ];then
    make_linuxptp_v4_0 || echo "Failed!"
fi
