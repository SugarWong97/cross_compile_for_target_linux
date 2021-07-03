##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Tue 24 Dec 2019 04:20:51 PM CST

##
#!/bin/sh

source ../.common

GDB_HOST=${OUTPUT_PATH}/gdb_host 
GDB_TARG=${OUTPUT_PATH}/gdbserver

download_package () {
    cd ${BASE}/compressed
    #下载包
    tget http://ftp.gnu.org/gnu/gdb/gdb-7.8.1.tar.xz
}

function make_gdb_host () {
function _make_sh () {
cat<<EOF
    ./configure --target=${BUILD_HOST} --prefix=${GDB_HOST}
EOF
}
    cd ${BASE}/source/gdb*

    _make_sh > $tmp_config
    source ./$tmp_config || return 1
    
    make clean
    make $MKTHD && make install
}

function make_gdb_target () {
function _make_sh () {
cat<<EOF
    ./configure --host=${BUILD_HOST} --prefix=${GDB_TARG}
EOF
}
    cd ${BASE}/source/gdb*/gdb/gdbserver

    _make_sh > $tmp_config
    source ./$tmp_config || return 1
    
    make clean
    make $MKTHD && make install
}

function make_build ()
{
    download_package  || return 1
    tar_package || return 1
    # arm gdb 分为2个部分
    make_gdb_host  || return 1
    make_gdb_target  || return 1
}

make_build || echo "Err"
