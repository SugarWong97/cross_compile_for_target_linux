##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Fri 22 Nov 2019 11:49:30 AM CST

##
#!/bin/sh

source ../.common

export JPEG=jpegsrc.v9c
JPEG_OUTPUT=${OUTPUT_PATH}/${JPEG}

function download_libjpeg () {
    tget    http://www.ijg.org/files/${JPEG}.tar.gz
}

function mk_libjpeg () {
    bash <<EOF

    cd ${BASE}/source/*

    ./configure \
    --prefix=${JPEG_OUTPUT}/ \
    --host=${BUILD_HOST}

    make clean
    make $MKTHD && make install
EOF
}

function make_libjpeg ()
{
    download_libjpeg  || return 1
    tar_package || return 1

    mk_libjpeg  || return 1
}

make_libjpeg || echo "Err"
