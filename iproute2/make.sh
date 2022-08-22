##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Fri 22 Nov 2019 11:49:30 AM CST

##
#!/bin/sh

source ../.common

IP_ROUTE2=iproute2-5.8.0
IP_ROUTE2_INSTALL=${OUTPUT_PATH}/${IP_ROUTE2}

download_package () {
    cd ${BASE}/compressed
    tget https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/${IP_ROUTE2}.tar.xz
}

make_iproute2 () {

    cp -v ${BASE}/meta/${IP_ROUTE2}/Makefile $CODE_PATH/${IP_ROUTE2}
    cp -v ${BASE}/meta/${IP_ROUTE2}/config.mk $CODE_PATH/${IP_ROUTE2}
    cd $CODE_PATH/${IP_ROUTE2}


    make CC=${_CC} PREFIX=${IP_ROUTE2_INSTALL} || return -1

    mkdir -p ${IP_ROUTE2_INSTALL}
    cp -v $CODE_PATH/${IP_ROUTE2}/ip/ip ${IP_ROUTE2_INSTALL}

    #make WITHOUT_XATTR=1 $MKTHD
    #do_copy
}

function make_build ()
{
    download_package  || return 1
    tar_package || return 1

    make_iproute2  || return 1
}

make_build || echo "Err"
