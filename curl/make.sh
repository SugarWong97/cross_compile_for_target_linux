##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make2.sh
#    Created  :  Tue 31 Mar 2020 10:09:09 AM CST

##
#!/bin/sh
source ../.common

download_package () {
    cd ${BASE}/compressed
    tget https://curl.haxx.se/download/curl-7.69.1.tar.gz
}

function make_curl () {
function _make_sh () {
cat<<EOF
    ./configure \
    --prefix=${OUTPUT_PATH}/curl \
    --host=${BUILD_HOST} \
    CC=${_CC} \
    CXX=${_CPP}
EOF
}
    cd ${BASE}/source/curl*

    _make_sh > $tmp_config
    source ./$tmp_config || return 1
    
    make clean
    make $MKTHD && make install
}

function make_build ()
{
    download_package  || return 1
    tar_package || return 1
    make_curl  || return 1
}

make_build || echo "Err"
