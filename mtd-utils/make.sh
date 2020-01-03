##
#    Copyright By Schips, All Rights Reserved
# 自定义变量

BUILD_HOST=arm-linux
BASE=`pwd`
OUTPUT_PATH=${BASE}/install
ZLIB=zlib-1.2.11
MTD_UTILS=mtd-utils-1.4.8
LZO=lzo-2.08
E2FSPROGS=e2fsprogs-1.41.14

make_dirs () {
    #为了方便管理，创建有关的目录
    cd ${BASE} && mkdir compressed install source -p
}

download_package () {
    cd ${BASE}/compressed

    wget -c https://www.zlib.net/${ZLIB}.tar.gz 
    wget -c http://www.oberhumer.com/opensource/lzo/download/${LZO}.tar.gz
    wget -c https://jaist.dl.sourceforge.net/project/e2fsprogs/e2fsprogs/1.41.14/${E2FSPROGS}.tar.gz
    wget -c ftp://ftp.infradead.org/pub/mtd-utils/${MTD_UTILS}.tar.bz2

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


#编译
make_zlib () {
    # 编译安装 zlib
    cd ${BASE}/source/${ZLIB}
    echo "ZLIB ABOUT"
    CC=${BUILD_HOST}-gcc ./configure --prefix=${OUTPUT_PATH}/${ZLIB}
    make && make install
}

make_lzo () {
    # 编译安装 lzo
    cd ${BASE}/source/${LZO}
    echo "LZO ABOUT"
    CC=${BUILD_HOST}-gcc ./configure --host=arm-linux  --prefix=${OUTPUT_PATH}/${LZO}
    make && make install
}

make_e2fsprogs () {
    # 编译安装 e2fsprogs
    cd ${BASE}/source/${E2FSPROGS}
    echo "E2FSPROGS ABOUT"
    CC=${BUILD_HOST}-gcc ./configure --host=arm-linux --enable-elf-shlibs --prefix=${OUTPUT_PATH}/${E2FSPROGS}
    make && make install-libs
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

    export CROSS=${BUILD_HOST}-
    export DESTDIR=${OUTPUT_PATH}/mtd-utils
    export ZLIBCPPFLAGS=-I${OUTPUT_PATH}/${ZLIB}/include
    export  LZOCPPFLAGS="-I${OUTPUT_PATH}/${LZO}/include -I{$OUTPUT_PATH}/${E2FSPROGS}/include/"
    export  ZLIBLDFLAGS=-L${OUTPUT_PATH}/${ZLIB}/lib
    export   LZOLDFLAGS=-L${OUTPUT_PATH}/${LZO}/lib
    export   UUIDLDLIBS=-L${OUTPUT_PATH}/${E2FSPROGS}/lib

    make WITHOUT_XATTR=1
    do_copy
}

 echo "Using ${BUILD_HOST}-gcc"
make_dirs
#download_package
tar_package
make_zlib
make_lzo
make_e2fsprogs
make_mtd_utils

