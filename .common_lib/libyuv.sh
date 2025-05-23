
LIBYUV_INSTALL=${OUTPUT_PATH}/libyuv

#下载包
download_libyuv () {
    # unofficial libyuv mirror
    tgit  https://github.com/lemenkov/libyuv
}

mk_libyuv () {
    cd ${CODE_PATH}/libyuv* || return 1

    local LIBYUV_DIR=`pwd`

    cp ${META_PATH}/Makefile ${LIBYUV_DIR}
    make CROSS_COMPILE=${BUILD_HOST_} TYPE=so
    make CROSS_COMPILE=${BUILD_HOST_} TYPE=a
    mkdir ${LIBYUV_INSTALL} -p
    cp -rfv ${LIBYUV_DIR}/include/ ${LIBYUV_INSTALL}

    mkdir ${LIBYUV_INSTALL}/lib -p
    cp -rfv $LIBYUV_DIR/libyuv.so ${LIBYUV_INSTALL}/lib
    cp -rfv $LIBYUV_DIR/libyuv.a ${LIBYUV_INSTALL}/lib
}


make_libyuv ()
{
    make_dirs
    download_libyuv || { echo >&2 "download_libyuv "; exit 1; }
    tar_package
    mk_libyuv
}
