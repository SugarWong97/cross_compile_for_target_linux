##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#
#    File Name:  make.sh
#    Created  :  2020-07-31 09:38:39
#
##
#!/bin/sh

BASE=`pwd`
BUILD_HOST=arm-linux
# 最终的运行环境
FIN_INSTALL=/usr/local/lighttpd


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
    tget https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.55.tar.gz
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

set_compile_env () {
    #GCC_PATH=`whereis gcc | awk -F: '{print $2}' | awk '{print $1}' | xargs dirname`
    #export PATH=$PATH:$GCC_PATH
	export CC=${BUILD_HOST}gcc
	export AR=${BUILD_HOST}ar
	export LD=${BUILD_HOST}ld
	export RANLIB=${BUILD_HOST}ranlib
	export STRIP=${BUILD_HOST}strip
}

make_taget () {
    cd ${BASE}/source/*
    ./configure --disable-ipv6 --disable-lfs  --without-bzip2 \
        --prefix=${FIN_INSTALL}  && echo "${FIN_INSTALL} with ${BUILD_HOST}gcc" > ${BASE}/ccinfo
    make 
}

make_install () {
    mkdir ${BASE}/install/lib  -p
    mkdir ${BASE}/install/sbin -p
    cd ${BASE}/source/*
    SRCTOP=`pwd`
    echo "${FIN_INSTALL} with ${BUILD_HOST}gcc" > ${BASE}/ccinfo
    cp ${BASE}/ccinfo               ${BASE}/install
    cp $SRCTOP/src/.libs/*.so       ${BASE}/install/lib  -r
    cp $SRCTOP/src/lighttpd-angel   ${BASE}/install/sbin
    cp $SRCTOP/src/lighttpd         ${BASE}/install/sbin
    #cp `find . -type f -name "lighttpd.conf" 2> /dev/null | grep doc` -v ${BASE}/install/sbin
    cp $SRCTOP/doc/config  -r       ${BASE}/install/
    rm  ${BASE}/install/config/Make*
}

make_dirs
set_compile_env
#tar_package
#make_taget
make_install
exit $?
