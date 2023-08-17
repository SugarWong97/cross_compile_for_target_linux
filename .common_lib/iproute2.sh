
IP_ROUTE2=iproute2-5.8.0
IP_ROUTE2_INSTALL=${OUTPUT_PATH}/${IP_ROUTE2}

download_iproute2 () {
    tget https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/${IP_ROUTE2}.tar.xz
}

mk_iproute2 () {

    cp -v ${BASE}/meta/${IP_ROUTE2}/Makefile $CODE_PATH/${IP_ROUTE2}
    cp -v ${BASE}/meta/${IP_ROUTE2}/config.mk $CODE_PATH/${IP_ROUTE2}

    file_replace_match_lines $CODE_PATH/${IP_ROUTE2}/config.mk "my_custom_ar" "AR:=${_AR}"
    file_replace_match_lines $CODE_PATH/${IP_ROUTE2}/config.mk "my_custom_cc" "CC:=${_CC}"

    cd $CODE_PATH/${IP_ROUTE2}


    make CC=${_CC} PREFIX=${IP_ROUTE2_INSTALL} || return -1

    mkdir -p ${IP_ROUTE2_INSTALL}
    mkdir -p ${IP_ROUTE2_INSTALL}/bin
    cp -v $CODE_PATH/${IP_ROUTE2}/ip/ip ${IP_ROUTE2_INSTALL}/bin

    #make WITHOUT_XATTR=1 $MKTHD
    #do_copy
}

function make_iproute2 ()
{
    download_iproute2  || return 1
    tar_package || return 1

    mk_iproute2  || return 1
}
