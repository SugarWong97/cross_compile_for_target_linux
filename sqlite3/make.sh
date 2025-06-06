##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Tue 24 Mar 2020 10:25:28 AM CST

##
#!/bin/sh
BASE=`pwd`
BUILD_HOST=arm-linux
OUTPUT_PATH=${BASE}/install/

make_dirs() {
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
    #下载包
    tget    https://www.sqlite.org/2020/sqlite-autoconf-3310100.tar.gz
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


configure_jpeg () {
    cd ${BASE}/source/*
    ./configure \
    --prefix=${OUTPUT_PATH}/${JPEG} \
    --host=${BUILD_HOST}
}

make_sqlite_host () {
    cp ${BASE}/source/sqlite* ${BASE}/source/_sqlite_for_host -r
    cd ${BASE}/source/_sqlite_for_host
    ./configure  --prefix=${OUTPUT_PATH}/sqlite_host 
    make && make install
}

make_sqlite_arm () {
    cp ${BASE}/source/sqlite* ${BASE}/source/_sqlite_for_arm -r
    cd ${BASE}/source/_sqlite_for_arm
    ./configure CC=${BUILD_HOST}-gcc --prefix=${OUTPUT_PATH}/sqlite_arm --host=arm-linux --build=i686-pc-linux-gnu
    make && make install
}
echo "Using ${BUILD_HOST}-gcc"
make_dirs
download_package
tar_package
configure_jpeg
make_sqlite_host
make_sqlite_arm
