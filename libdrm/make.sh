##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Mon 02 Sep 2019 11:39:38 AM HKT
##
#!/bin/zsh

source ../.common

LIBDRM_DIR=${OUTPUT_PATH}/libdrm

download_libdrm () {
    #https://dri.freedesktop.org/libdrm/
    tget https://dri.freedesktop.org/libdrm/libdrm-2.4.89.tar.bz2
}

function make_libdrm () {
function _make_sh () {
cat<<EOF
     ./configure \
    --host=${BUILD_HOST} \
    --prefix=${LIBDRM_DIR} \
    --enable-static
    --enable-shared
EOF
    #--with-plugindir=/usr/local/lib/alsa_lib
}
    cd ${CODE_PATH}/libdrm*

    _make_sh > $tmp_config
    source ./$tmp_config
    make clean
    make  $MKTHD && make install
}

function build_libdrm ()
{
    download_libdrm || return 1
    tar_package || return 1
    make_libdrm || return 1
}
build_libdrm || echo "Err"
