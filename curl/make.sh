##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make2.sh
#    Created  :  Tue 31 Mar 2020 10:09:09 AM CST

##
#!/bin/sh
HOST=arm-linux-gnueabi
BASE=`pwd`
OUTPUT_PATH=${BASE}/install
ARM_GCC=${HOST}-gcc


make_dirs () {
    cd ${BASE}
    mkdir  compressed  install  source -p
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
    tget https://curl.haxx.se/download/curl-7.69.1.tar.gz
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

make_curl () {
    cd ${BASE}/source/curl*
    ./configure --prefix=${OUTPUT_PATH}/${ZLIB} --host=${HOST} CC=${HOST}-gcc CXX=${HOST}-g++  && make && make install
    
}

make_dirs
download_package
tar_package
make_curl
