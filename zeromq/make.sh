##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Dec 12 Nov 2022 17:49:30 PM CST

##
#!/bin/sh

source ../.common

export ZEROMQ=zeromq-4.3.4
OUTPUT=${OUTPUT_PATH}/${ZEROMQ}

function download_zeromq () {
    tget            https://github.com/zeromq/libzmq/releases/download/v4.3.4/zeromq-4.3.4.tar.gz
    tget_and_rename https://github.com/zeromq/cppzmq/archive/refs/tags/v4.8.0.tar.gz  cppzmq-4.8.0.tar.gz
}

function mk_zeromq () {
    bash <<EOF

    cd ${BASE}/source/zeromq*

    ./configure   --without-libsodium \
    --prefix=${OUTPUT}/ \
    --host=${BUILD_HOST}

    make clean
    make $MKTHD && make install
EOF
}

function get_zeromq_hpp () {
    bash <<EOF

    cd ${BASE}/source/cppzmq*
    cp -v *.hpp ${OUTPUT}/include
EOF
}

function make_zeromq ()
{
    download_zeromq  || return 1
    tar_package || return 1

    mk_zeromq  || return 1
    get_zeromq_hpp
}

make_zeromq || echo "Failed!"
