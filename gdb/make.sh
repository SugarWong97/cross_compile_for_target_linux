##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Tue 24 Dec 2019 04:20:51 PM CST

##
#!/bin/sh
BASE=`pwd`
BUILD_HOST=arm-linux


OUTPUT_PATH=${BASE}/install/

make_dirs() {
    cd ${BASE}
    mkdir  compressed  install  source -p
    sudo ls
}
tget () { #try wget
    filename=`basename $1`
    echo "Downloading [${filename}]..."
    if [ ! -f ${filename} ];then
        wget $1
    fi

    echo "[OK] Downloaded [${filename}] "
}

download_package () {
    cd ${BASE}/compressed
    #下载包
    tget http://ftp.gnu.org/gnu/gdb/gdb-7.8.1.tar.xz
}

tar_package () {
    cd ${BASE}/compressed
    ls * > /tmp/list.txt
    for TAR in `cat /tmp/list.txt`
    do
        tar -xf $TAR -C  ../source
    done
    rm -rf /tmp/list.txt
}
make_gdb_host () {
    cd ${BASE}/source/gdb*
    ./configure --target=${BUILD_HOST} --prefix=${OUTPUT_PATH}/gdb_host 
    make && make install
    
}

make_gdb_target () {
    cd ${BASE}/source/gdb*/gdb/gdbserver
    ./configure --host=${BUILD_HOST} --prefix=${OUTPUT_PATH}/gdbserver
    make && make install
}


make_dirs
download_package
tar_package
# arm gdb 分为2个部分
make_gdb_host
make_gdb_target
exit $?

