##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Fri 22 Nov 2019 11:49:30 AM CST

##
#!/bin/sh

source ../.common

JPEG=jpegsrc.v9c
JPEG_OUTPUT=${OUTPUT_PATH}/${JPEG}

download_package () {
    cd ${BASE}/compressed
    #下载包
    tget    http://www.ijg.org/files/${JPEG}.tar.gz
}

function make_jpeg () {
function _make_sh () {
cat<<EOF
    ./configure \
    --prefix=${JPEG_OUTPUT}/ \
    --host=${BUILD_HOST}
EOF
}
    cd ${BASE}/source/*

    _make_sh > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make $MKTHD && make install
}

function make_build ()
{
    download_package  || return 1
    tar_package || return 1

    make_jpeg  || return 1
}

make_build || echo "Err"
