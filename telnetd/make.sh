##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  2022-9-27 13:56:40

##
#!/bin/sh

source ../.common

TELNETD=telnetd
TELNETD_INSTALL=${OUTPUT_PATH}/${TELNETD}

YOURSH=yoursh
YOURSH_INSTALL=${OUTPUT_PATH}/${YOURSH}

download_package () {
    cd ${BASE}/compressed

    # 这2个都是Telnet服务程序

    # telnetd 不允许空密码登录
    tgit https://github.com/neilrob2016/telnetd.git
    # yoursh 无需密码即可登录
    tgit https://github.com/poilynx/yoursh.git
}

make_telnetd () {
    cd $CODE_PATH/${TELNETD}

    make CC=${_CC} LD=${_LD}

    cp -v $CODE_PATH/${TELNETD}/telnetd ${TELNETD_INSTALL}
}

make_yoursh () {
    cd $CODE_PATH/${YOURSH}

    make CC=${_CC} LD=${_LD}

    cp -v $CODE_PATH/${YOURSH}/yoursh ${YOURSH_INSTALL}
}

function make_build ()
{
    download_package  || return 1
    tar_package || return 1

    make_telnetd  || return 1
    make_yoursh  || return 1
}

make_build || echo "Err"
