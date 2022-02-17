##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Mon 02 Sep 2019 11:39:38 AM HKT
##
#!/bin/zsh

source ../.common
export LIBDRM=libdrm-2.4.89
LIBDRM_DIR=${OUTPUT_PATH}/libdrm

download_libdrm () {
    #https://dri.freedesktop.org/libdrm/
    tget https://dri.freedesktop.org/libdrm/${LIBDRM}.tar.bz2
}

function make_libdrm () {
bash <<EOF

    cd ${CODE_PATH}/libdrm*

     ./configure \
    --host=${BUILD_HOST} \
    --prefix=${LIBDRM_DIR} \
    --enable-static \
    --enable-shared
    #--with-plugindir=/usr/local/lib/alsa_lib

    make  $MKTHD
    make install
EOF
}

function build_libdrm ()
{
    download_libdrm || return 1
    tar_package || return 1
    make_libdrm || return 1
}
build_libdrm || echo "Err"
