##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Fri 22 Nov 2019 10:38:53 AM CST

##
#!/bin/sh
BUILD_HOST=arm-linux
PHP=php-7.1.30
ZLIB=zlib-1.2.11
XML2=libxml2-2.9.9
ICONV=libiconv-1.15

FIN_INSTALL=/usr/${PHP}

BASE=`pwd`
OUTPUT_PATH=${BASE}/install
ARM_GCC=${BUILD_HOST}-gcc


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
    tget http://mirrors.sohu.com/php/${PHP}.tar.gz
    tget https://www.zlib.net/${ZLIB}.tar.gz
    tget http://distfiles.macports.org/libxml2/${XML2}.tar.gz
    tget http://ftp.gnu.org/pub/gnu/libiconv/${ICONV}.tar.gz
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
 

make_zlib () {
    cd ${BASE}/source/${ZLIB}
    CC=${ARM_GCC} ./configure --prefix=${OUTPUT_PATH}/${ZLIB} && make && make install

}

make_xml2 () {
    cd ${BASE}/source/${XML2}

    ./configure \
    --without-zlib \
    --without-lzma \
    --without-python \
    --prefix=${OUTPUT_PATH}/${XML2} \
    --BUILD_HOST=${BUILD_HOST} && make && make install
}


make_iconv () {
    cd ${BASE}/source/${ICONV}

    ./configure --BUILD_HOST=${BUILD_HOST} \
    --prefix=${OUTPUT_PATH}/${ICONV} && make && make install
}

configure_php () {
    cd ${BASE}/source/${PHP}
    ./configure \
    --prefix=${FIN_INSTALL} \
    --BUILD_HOST=${BUILD_HOST} \
    --libdir=/tmp \
    --datadir=/tmp \
    --includedir=/tmp \
    --oldincludedir=/tmp \
    --datarootdir=/tmp \
    --sharedstatedir=/tmp \
    --libexecdir=${FIN_INSTALL}/libexec \
    --with-config-file-path=${FIN_INSTALL}/etc \
	--localstatedir=${FIN_INSTALL}/var \
    --bindir=${FIN_INSTALL}/bin \
    --sbindir=${FIN_INSTALL}/sbin \
	--sysconfdir=${FIN_INSTALL}/etc \
	--runstatedir=${FIN_INSTALL}/var/run \
    --with-config-file-scan-dir=${FIN_INSTALL}/etc/php-fpm.d \
    --disable-all \
    --disable-phpdbg \
    --enable-cgi \
    --enable-json \
    --enable-posix \
    --enable-pcntl \
    --enable-session \
    --enable-fpm \
    --enable-libxml \
    --enable-dom \
    --enable-hash \
    --with-sqlite3 \
    --enable-zip \
    --enable-ctype \
    --enable-simplexml \
    --with-zlib=${OUTPUT_PATH}/${ZLIB} \
    --with-libxml-dir=${OUTPUT_PATH}/${XML2} \
    --with-iconv-dir=${OUTPUT_PATH}/${ICONV} \
    --enable-xml \
    --enable-mbstring \
    --enable-xmlreader && echo "${FIN_INSTALL} with ${BUILD_HOST}" > readme
}

make_php () {
    cd ${BASE}/source/${PHP}
    make -j4 && sudo make install && sudo mv readme ${FIN_INSTALL}/readme
    sudo mv ${FIN_INSTALL} ${OUTPUT_PATH}/${PHP}
    cd ${BASE}/install/${PHP}/ && sudo rm lib php -rf
    cd ${BASE}
}
make_dirs
sudo ls
download_package
tar_package
make_zlib
make_xml2
make_iconv
configure_php
make_php

exit $?


