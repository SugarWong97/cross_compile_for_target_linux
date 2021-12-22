##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Tue 24 Dec 2019 04:20:51 PM CST

##
#!/bin/sh

source ../.common

#GDB_VERSION=gdb-7.8.1
GDB_VERSION=gdb-9.2
GDB_HOST=${OUTPUT_PATH}/gdb_host 
GDB_TARG=${OUTPUT_PATH}/gdbserver
GDB_PATH=${BASE}/source/$GDB_VERSION

download_package () {
    cd ${BASE}/compressed
    #tget http://ftp.gnu.org/gnu/gdb/gdb-7.8.1.tar.xz
    tget http://ftp.gnu.org/gnu/gdb/${GDB_VERSION}.tar.gz
}

function make_gdb_host () {
    cd $GDB_PATH
    local here=`pwd`/build/

    (
    cat<<EOF
    rm  build -rf
    mkdir build
    cd build
    \`pwd\`/../configure --target=${BUILD_HOST} --prefix=${GDB_HOST}
    #make clean
    make $MKTHD && make install
EOF
) > $tmp_config
    bash ./$tmp_config || return 1
    
}

function make_gdb_target () {
    cd $GDB_PATH/gdb/gdbserver

    (
    cat<<EOF
    rm  build -rf
    mkdir build
    cd build
    \`pwd\`/../configure --host=${BUILD_HOST} --prefix=${GDB_TARG}
    #make clean
    make $MKTHD && make install
EOF
) > $tmp_config
    bash ./$tmp_config || return 1
    
}

function make_build ()
{
    #sudo apt-get install -y texinfo
    download_package  || return 1
    tar_package || return 1
    # arm gdb 分为2个部分
    make_gdb_host  || return 1
    make_gdb_target  || return 1
}

make_build || echo "Err"
