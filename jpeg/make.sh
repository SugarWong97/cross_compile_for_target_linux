##
#!/bin/sh
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Fri 22 Nov 2019 11:49:30 AM CST

##
#!/bin/sh
BASE=`pwd`
BUILD_HOST=arm-linux
JPEG=jpegsrc.v9c
OUTPUT=${BASE}/install/

make_dirs() {
    cd ${BASE}
    mkdir  compressed  install  source -p

}

download_package () {
    cd ${BASE}/compressed
    #下载包
    wget    http://www.ijg.org/files/${JPEG}.tar.gz
}

tar_package () {
    cd ${BASE}/compressed
    #解压下载的包
    tar -C ${BASE}/source -xf ${JPEG}.tar.gz
}



configure_jpeg () {
    cd ${BASE}/source/*
    ./configure \
    --prefix=${OUTPUT}/${JPEG} \
    --host=${BUILD_HOST}
}


make_jpeg () {
    cd ${BASE}/source/*
	make -j4 && make install
}
echo "Using ${BUILD_HOST}-gcc"
make_dirs
download_package
tar_package
configure_jpeg
make_jpeg
