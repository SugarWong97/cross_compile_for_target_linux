## **背景：**

PHP 是世界上最好的语言。

> host平台　　 ：Ubuntu 16.04
> arm平台　　 ： 3531d
> arm-gcc　　 ：4.9.4
> 
> [php](http://mirrors.sohu.com/php/)　　 　　：[7.1.30](http://mirrors.sohu.com/php/php-7.1.30.tar.gz)
> [zlib](http://www.zlib.net/)　　　　 ：[1.2.11](https://www.zlib.net/zlib-1.2.11.tar.gz)
> [libxml2](http://distfiles.macports.org/libxml2/)　　  ： [2.9.9](http://distfiles.macports.org/libxml2/libxml2-2.9.9.tar.gz)
> [libiconv](http://ftp.gnu.org/pub/gnu/libiconv/)　　 ：[1.15](http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz)
>



## **主机准备：**

使用以下脚本

```
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
#    Created  :  Fri 22 Nov 2019 10:38:53 AM CST
##
#!/bin/sh
HOST=arm-linux
PHP=php-7.1.30
ZLIB=zlib-1.2.11
XML2=libxml2-2.9.9
ICONV=libiconv-1.15

FIN_INSTALL=/usr/${PHP}

BASE=`pwd`
OUTPUT_PATH=${BASE}/install
ARM_GCC=${HOST}-gcc


make_dirs () {
    cd ${BASE}
    mkdir  compressed  install  source -p
}

download_package () {
    cd ${BASE}/compressed
    wget http://mirrors.sohu.com/php/${PHP}.tar.gz
    wget -c https://www.zlib.net/${ZLIB}.tar.gz
    wget -c http://distfiles.macports.org/libxml2/${XML2}.tar.gz
    wget http://ftp.gnu.org/pub/gnu/libiconv/${ICONV}.tar.gz
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
    --host=${HOST} && make && make install
}


make_iconv () {
    cd ${BASE}/source/${ICONV}

    ./configure --host=${HOST} \
    --prefix=${OUTPUT_PATH}/${ICONV} && make && make install
}

configure_php () {
    cd ${BASE}/source/${PHP}
    ./configure \
    --prefix=${FIN_INSTALL} \
    --host=${HOST} \
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
    --enable-xmlreader && echo "${FIN_INSTALL} with ${HOST}" > readme
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
#download_package
tar_package
make_zlib
make_xml2
make_iconv
configure_php
make_php
```



**自此，编译完成**



## arm板准备

将php依赖的动态库zlib，libxml2 ，libiconv移动到开发板中（注意软连接的保持）。 

**测试（在arm板子上）**

进入php/bin
```
./php -i
```

此后，可以进行与nginx搭配等配置（略）

## 附录:优化体积的可选步骤

strip处理：

`${HOST}-strip php`

UPX处理：

```
upx php

​            Ultimate Packer for eXecutables

​             Copyright (C) 1996 - 2013

UPX 3.91    Markus Oberhumer, Laszlo Molnar & John Reiser  Sep 30th 2013

​    File size     Ratio   Format   Name

--------------------  ------  -----------  -----------

  3679836 ->  1357148  36.88%  linux/armel  php             

Packed 1 file.
```

