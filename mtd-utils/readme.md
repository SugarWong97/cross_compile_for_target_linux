有关文章：《[mtd-utils 的 使用](https://www.cnblogs.com/schips/p/11712028.html)》、《[使用 mtd-utils 烧写Arm Linux 系统各个部分](https://www.cnblogs.com/schips/p/12102099.html)》

## 背景：

　　关于在公司的生产环境有关。不希望每次都在uboot下面做nand flash 的烧写；也觉得使用U盘升级的方法比较慢，而且有关的驱动不是我写的，不希望受制于人。还是希望在Linux下面比较通用。

 

**要求： 根据本文进行操作时，需要明确清楚各个部分的烧写地址和大小。**

 

 

host平台　　 ：Ubuntu 16.04

arm平台　　 ： 3531d

 

[mtd-utils](ftp://ftp.infradead.org/pub/mtd-utils/)　　 ：1.4.8

[zlib](http://www.zlib.net/)　　　　  ：1.2.11

[lzo](http://www.oberhumer.com/opensource/lzo/download/)　　　　   ：2.08

[e2fsprogs](http://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/)　 ： 1.41.14


arm-gcc　　 ：4.9.4

 

## 编译

一个脚本解决所有的事情



```
##
#    Copyright By Schips, All Rights Reserved
# 自定义变量

OUTPUT_PATH=`pwd`/install
BUILD_HOST=arm-linux-
ARM_GCC=${BUILD_HOST}gcc
BASE=`pwd`
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

    #wget -c https://www.zlib.net/${ZLIB}.tar.gz 
    #wget -c http://www.oberhumer.com/opensource/lzo/download/${LZO}.tar.gz
    # 注意下面这行的网址
    #wget -c https://jaist.dl.sourceforge.net/project/e2fsprogs/e2fsprogs/1.41.14/${E2FSPROGS}.tar.gz
    #wget -c ftp://ftp.infradead.org/pub/mtd-utils/${MTD_UTILS}.tar.bz2

}
tar_package () {
    cd ${BASE}/compressed

    #解压下载的包
    tar -C ../source -xf ${ZLIB}.tar.gz 
    tar -C ../source -xf ${LZO}.tar.gz
    tar -C ../source -xf ${E2FSPROGS}.tar.gz
    tar -C ../source -xf ${MTD_UTILS}.tar.bz2
}
#编译
# 有些人喜欢把交叉库编译到工具链中以简化编译的操作步骤，本人觉得这样的做法是非常错误的。（会对工具链造成污染）

make_zlib () {
    # 编译安装 zlib
    cd ${BASE}/source/${ZLIB}
    echo "ZLIB ABOUT"
    CC=${ARM_GCC} ./configure --prefix=${OUTPUT_PATH}/${ZLIB}
    make && make install
}

make_lzo () {
    # 编译安装 lzo
    cd ${BASE}/source/${LZO}
    echo "LZO ABOUT"
    CC=${ARM_GCC} ./configure --host=arm-linux  --prefix=${OUTPUT_PATH}/${LZO}
    make && make install
}

make_e2fsprogs () {
    # 编译安装 e2fsprogs
    cd ${BASE}/source/${E2FSPROGS}
    echo "E2FSPROGS ABOUT"
    CC=${ARM_GCC} ./configure --host=arm-linux --enable-elf-shlibs --prefix=${OUTPUT_PATH}/${E2FSPROGS}
    make && make install-libs
    mkdir ${OUTPUT_PATH}/${E2FSPROGS}/include/uuid -p
    cp lib/uuid/uuid.h ${OUTPUT_PATH}/${E2FSPROGS}/include/uuid
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

    export CROSS=${BUILD_HOST}
    export DESTDIR=${OUTPUT_PATH}/mtd-utils
    export ZLIBCPPFLAGS=-I${OUTPUT_PATH}/${ZLIB}/include
    export  LZOCPPFLAGS="-I${OUTPUT_PATH}/${LZO}/include -I{$OUTPUT_PATH}/${E2FSPROGS}/include/"
    export  ZLIBLDFLAGS=-L${OUTPUT_PATH}/${ZLIB}/lib
    export   LZOLDFLAGS=-L${OUTPUT_PATH}/${LZO}/lib
    export   UUIDLDLIBS=-L${OUTPUT_PATH}/${E2FSPROGS}/lib

    make WITHOUT_XATTR=1
}

make_dirs
#download_package
tar_package
make_zlib
make_lzo
make_e2fsprogs
make_mtd_utils
```



 

mtd-utils：

make 后　　　　  ：mtd-utilsg工具链将会在当前目录下$CROSS目录生成

make install后　　：make生成的结果将安装到DESTDIR目录下

\* 如果 make install 失败，手动在 $CROSS 文件名的目录下就可以找到编译的结果

 

 ![img](https://img2018.cnblogs.com/blog/1281523/201910/1281523-20191021115158504-1099291665.png)

 拷贝需要的程序和库即可

 

 **mtd-utils 2.0版本的编译：** https://blog.csdn.net/liyangzmx/article/details/93901411

（注：本人尝试过2.x版本的编译，但是失败了。）
