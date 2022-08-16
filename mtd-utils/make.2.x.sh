##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Fri 22 Nov 2019 11:49:30 AM CST

##
#!/bin/sh

source ../.common

MTD_UTILS=mtd-utils-2.0.0-rc2
LZO=lzo-2.08
E2FSPROGS=e2fsprogs-1.42.12

download_package () {
    cd ${BASE}/compressed

    tget https://www.zlib.net/${ZLIB}.tar.gz
    tget http://www.oberhumer.com/opensource/lzo/download/${LZO}.tar.gz
    #tget https://jaist.dl.sourceforge.net/project/e2fsprogs/e2fsprogs/1.41.14/${E2FSPROGS}.tar.gz
    tget https://jaist.dl.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.42.12/e2fsprogs-1.42.12.tar.gz
    tget ftp://ftp.infradead.org/pub/mtd-utils/${MTD_UTILS}.tar.bz2
}

#编译
function make_lzo () {
function _make_sh () {
cat<<EOF
    CC=${_CC} ./configure --host=arm-linux  --prefix=${OUTPUT_PATH}/${LZO}
EOF
}
    # 编译安装 lzo
    cd ${BASE}/source/${LZO}

    _make_sh > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make $MKTHD && make install
}

function make_e2fsprogs () {
function _make_sh () {
cat<<EOF
    CC=${_CC} ./configure --host=arm-linux --enable-elf-shlibs --prefix=${OUTPUT_PATH}/${E2FSPROGS} --without-libintl-prefix
EOF
}
    # 编译安装 e2fsprogs
    cd ${BASE}/source/${E2FSPROGS}

    _make_sh > $tmp_config
    source ./$tmp_config || return 1

    make $MKTHD && make install-libs
    mkdir ${OUTPUT_PATH}/${E2FSPROGS}/include/uuid -p
    cp lib/uuid/uuid.h ${OUTPUT_PATH}/${E2FSPROGS}/include/uuid
}

do_copy() {
    cd ${BASE}/source/${MTD_UTILS}/${BUILD_HOST}
    rm *.o
    cp ${BASE}/source/${MTD_UTILS}/${BUILD_HOST}  ${OUTPUT_PATH}/${MTD_UTILS} -r
}

make_mtd_utils () {
    # 编译安装 mtd-utils
    cd ${BASE}/source/${MTD_UTILS}
    echo "MTD ABOUT"
    # 下面4行修复了mtd编译的一些问题
    sed -r -i "/LDLIBS_mkfs.ubifs = -lz -llzo2 -lm -luuid/ s/.*/LDLIBS_mkfs.ubifs = -lz -llzo2 -lm -luuid \$(ZLIBLDFLAGS) \$(LZOLDFLAGS) \$(UUIDLDLIBS)/g" Makefile
    sed -r -i "/#include <uuid\/uuid.h>/ s/.*/#include \"uuid\/uuid.h\"/g" mkfs.ubifs/mkfs.ubifs.h
    mkdir mkfs.ubifs/uuid -p
    cp ${BASE}/source/${E2FSPROGS}/lib/uuid/uuid.h mkfs.ubifs/uuid/uuid.h

    export CROSS=${BUILD_HOST_}
    export ZLIBCPPFLAGS="-I${OUTPUT_PATH}/${ZLIB}/include"
    export  LZOCPPFLAGS="-I${OUTPUT_PATH}/${LZO}/include -I{$OUTPUT_PATH}/${E2FSPROGS}/include/"
    export  ZLIBLDFLAGS="-L${OUTPUT_PATH}/${ZLIB}/lib"
    export   LZOLDFLAGS="-L${OUTPUT_PATH}/${LZO}/lib"
    export   UUIDLDLIBS="-L${OUTPUT_PATH}/${E2FSPROGS}/lib"

    make WITHOUT_XATTR=1 $MKTHD
    do_copy
}

make_mtd_utils_new () {

    export DESTDIR=${OUTPUT_PATH}/mtd-utils
    export ZLIBCPPFLAGS="-I${OUTPUT_PATH}/${ZLIB}/include"
    export  LZOCPPFLAGS="-I${OUTPUT_PATH}/${LZO}/include -I{$OUTPUT_PATH}/${E2FSPROGS}/include/"
    export  ZLIBLDFLAGS="-L${OUTPUT_PATH}/${ZLIB}/lib"
    export   LZOLDFLAGS="-L${OUTPUT_PATH}/${LZO}/lib"
    export   UUIDLDLIBS="-L${OUTPUT_PATH}/${E2FSPROGS}/lib"

    mytmp=${DESTDIR}/../tmp/
    mkdir $mytmp
    mkdir $mytmp/include
    mkdir $mytmp/lib
    cp -r ${OUTPUT_PATH}/${ZLIB}/lib       $mytmp/lib
    cp -r ${OUTPUT_PATH}/${ZLIB}/include   $mytmp/include

    cp -r ${OUTPUT_PATH}/${LZO}/lib       $mytmp/lib
    cp -r ${OUTPUT_PATH}/${LZO}/include   $mytmp/include

    cp -r ${OUTPUT_PATH}/${E2FSPROGS}/lib       $mytmp/lib
    cp -r ${OUTPUT_PATH}/${E2FSPROGS}/include   $mytmp/include

    export LDFLAGS="${ZLIBLDFLAGS} ${LZOLDFLAGS}/ ${UUIDLDLIBS}"
    export CFLAGS="${ZLIBCPPFLAGS} ${LZOCPPFLAGS}/"
    # 编译安装 mtd-utils
    cd ${BASE}/source/${MTD_UTILS}
    echo "MTD ABOUT"
    export PKG_CONFIG_PATH=$mytmp/lib/pkgconfig
    ./configure --host=${BUILD_HOST} CC=${CC} --prefix=/ \
        WITHOUT_XATTR=1   --without-crypto \
        LDFLAGS="${LDFLAGS}"\
        CFLAGS="${CFLAGS} -g -O2"\
        LZO_CFLAGS="${LZOCPPFLAGS}" \
        ZLIB_CFLAGS="${ZLIBCPPFLAGS}" \
        UUID_CFLAGS="-I${OUTPUT_PATH}/${E2FSPROGS}/include"
    make WITHOUT_XATTR=1 $MKTHD
    make install

    #make WITHOUT_XATTR=1 $MKTHD
    #do_copy
}

function make_build ()
{
    download_package  || return 1
    tar_package || return 1

    make_zlib  || return 1
    make_lzo  || return 1
    make_e2fsprogs  || return 1
    make_mtd_utils_new  || return 1
}

make_build || echo "Err"
