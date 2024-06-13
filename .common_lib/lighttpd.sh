
# 最终的运行环境
FIN_INSTALL_LIGHTTPD=/usr/local/lighttpd

download_lighttpd () {
    cd ${BASE}/compressed
    #下载包
    tget https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.55.tar.gz
}

function mk_lighttpd  () {
function _make_sh () {
cat<<EOF
    ./configure --disable-ipv6 \
    --disable-lfs  --without-bzip2 \
    --without-zlib \
    --without-pcre \
    --without-openssl \
    --host=${BUILD_HOST} \
    --prefix=${FIN_INSTALL_LIGHTTPD}
EOF
}
    cd ${BASE}/source/*

    _make_sh > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make $MKTHD
}

mk_lighttpd_install () {
    mkdir ${BASE}/install/lib  -p
    mkdir ${BASE}/install/sbin -p
    cd ${BASE}/source/*
    SRCTOP=`pwd`
    echo "${FIN_INSTALL_LIGHTTPD} with ${BUILD_HOST}gcc" > ${BASE}/install/ccinfo
    cp $SRCTOP/src/.libs/*.so       ${OUTPUT_PATH}/lib  -r
    cp $SRCTOP/src/lighttpd-angel   ${OUTPUT_PATH}/sbin
    cp $SRCTOP/src/lighttpd         ${OUTPUT_PATH}/sbin
    cp $SRCTOP/doc/config  -r       ${OUTPUT_PATH}
    rm  ${OUTPUT_PATH}/config/Make*
}

function make_lighttpd ()
{
    download_lighttpd  || return 1
    tar_package || return 1
    mk_lighttpd && mk_lighttpd_install
}

