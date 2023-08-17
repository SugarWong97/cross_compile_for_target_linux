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

if [ "$LINUXPTP_VERSION" = "3.1" ];then
    make_linuxptp_v3_1 || echo "Failed!"
fi
if [ "$LINUXPTP_VERSION" = "4.0" ];then
    make_linuxptp_v4_0 || echo "Failed!"
fi
