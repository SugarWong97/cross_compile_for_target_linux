## 背景

Ffmpeg 中带有h264的解码,没有编码,需要添加x264。libx264是一个自由的H.264编码库，是x264项目的一部分，使用广泛，ffmpeg的H.264实现就是用的libx264。

FFmpeg是一套可以用来记录、转换数字音频、视频，并能将其转化为流的开源计算机程序。采用LGPL或GPL许可证。它提供了录制、转换以及流化音视频的完整解决方案。

librtmp用来接收、发布RTMP协议格式的数据。FFmpeg支持RTMP协议，将librtmp编译进去后支持协议RTMPE、RMTPTE、RTMPS。这里我直接使用FFmpeg自带的RTMP功能。

host平台　　 ：Ubuntu 18.04

arm平台　　 ： S5P6818

[x264](http://download.videolan.org/pub/videolan/x264/snapshots/)　 ：[20171212](http://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20171212-2245.tar.bz2)
[x265](http://download.videolan.org/videolan/x265/)　 ：[v2.6](http://download.videolan.org/videolan/x265/x265_2.6.tar.gz)

[ffmpeg](http://ffmpeg.org/releases/) 　 ：[4.0.1](http://ffmpeg.org/releases/ffmpeg-4.0.1.tar.bz2)

arm-gcc　　 ：4.8.1

使用以下脚本一键编译。
```
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Mon 02 Sep 2019 08:05:53 PM HKT
##
#!/bin/sh
BASE=`pwd`
BUILD_HOST=arm-linux
OUTPUT_PATH=${BASE}/install

OTHER_LIB=${OUTPUT_PATH}/__all_without_ffmpeg

make_dirs () {
    #为了方便管理，创建有关的目录
    cd ${BASE} && mkdir compressed install source -p
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
    tget http://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20171212-2245.tar.bz2
    tget http://ffmpeg.org/releases/ffmpeg-4.0.1.tar.bz2
    tget http://download.videolan.org/videolan/x265/x265_2.6.tar.gz
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

make_x264() {
    cd ${BASE}/source/x264*

    CC=${BUILD_HOST}-gcc \
    ./configure \
    --host=${BUILD_HOST} \
    --enable-shared \
    --enable-static \
    --enable-pic \
    --prefix=${OUTPUT_PATH}/x264 \
    --cross-prefix=${BUILD_HOST}- \
    --disable-asm

    make -j4 && make install
}

make_x265() {
    #sudo apt-get install cmake -y
    # 其他编译选项可以 通过 在 cmake ../source 以后 ccmake ../source 可以查看 ( ccmake 可以通过 sudo apt-get install cmake-curses-gui  进行安装 )
        cd ${BASE}/source/x265*/source
    # 获取 工具链所在位置 下面的操作为的是在 CMakeLists.txt 中插入下面内容
    GCC_FULL_PATH=`whereis ${BUILD_HOST}-gcc | awk -F: '{ print $2 }' | awk '{print $1}'` # 防止多个结果
    GCC_DIR=`dirname ${GCC_FULL_PATH}/`
    sed -i "1i\set( CMAKE_SYSTEM_NAME Linux  )"                         CMakeLists.txt
    sed -i "2a\set( CMAKE_SYSTEM_PROCESSOR ARM  )"                      CMakeLists.txt
    sed -i "2a\set( CMAKE_C_COMPILER ${GCC_DIR}/${BUILD_HOST}-gcc  )"   CMakeLists.txt
    sed -i "2a\set( CMAKE_CXX_COMPILER ${GCC_DIR}/${BUILD_HOST}-g++  )" CMakeLists.txt
    sed -i "2a\set( CMAKE_FIND_ROOT_PATH ${GCC_DIR} )"                  CMakeLists.txt
    cmake ../source
    # 指定安装路径
    sed -i "1i\set( CMAKE_INSTALL_PREFIX "${BASE}/install/x265"  )"     cmake_install.cmake
    make && make install
}
prepare_other_lib () {
    # 这一个是针对 ffmpeg 方便管理外部库使用的
    # 核心思想是把 所有的库都放到一起，再让 ffmpeg ld的时候在这里找（而不是添加多行） --extra-cflags="-I${X264_DIR}/include -I${xxx}/include" \
    cd ${BASE}/install/
    rm ${OTHER_LIB} -rf
    ls > /tmp/list.txt
    mkdir ${OTHER_LIB} -p
    for sub_dir in `cat /tmp/list.txt`
    do
        cp ${sub_dir}/* ${OTHER_LIB} -r -v
    done
    rm -rf /tmp/list.txt
}
make_ffmpeg() {
    cd ${BASE}/source/ffmpeg*
    ./configure \
    --cross-prefix=${BUILD_HOST}- \
    --enable-cross-compile \
    --target-os=linux \
    --cc=${BUILD_HOST}-gcc \
    --arch=arm \
    --prefix=${OUTPUT_PATH}/ffmpeg \
    --enable-shared \
    --enable-static \
    --enable-gpl \
    --enable-nonfree \
    --enable-ffmpeg \
    --disable-ffplay \
    --enable-ffserver \
    --enable-swscale \
    --enable-pthreads \
    --disable-armv5te \
    --disable-armv6 \
    --disable-armv6t2 \
    --disable-yasm \
    --disable-stripping \
    --enable-libx264 \
    --extra-cflags=-I${OTHER_LIB}/include \
    --extra-ldflags=-L${OTHER_LIB}/lib
    make clean && make -j4 && make install
}
echo "Using ${BUILD_HOST}-gcc"
make_dirs
download_package
tar_package
make_x264
make_x265
prepare_other_lib
make_ffmpeg
```

配置完成以后可能会有这个警告，但是不影响后续的结果

```
License: nonfree and unredistributable
Creating configuration files ...

WARNING: The --disable-yasm option is only provided for compatibility and will be
 removed in the future. Use --enable-x86asm / --disable-x86asm instead.
WARNING: unknown architecture linux
WARNING: using libx264 without pkg-config
```

## 开发板准备：

拷贝 __all_without_ffmpeg 中的 lib下的所有文件到板子上的/usr/lib 中，同样地，拷贝ffmpeg中的lib到板子上。

## 测试：

```bash
 ffmpeg -f video4linux2 -s 320x240 -i /dev/video0 /mnt/tmp/test.avi 
 # video4linux2 代表Linux下  
 # /dev/video0 代表摄像头设备 
 # /mnt/tmp/test.avi代表输出路径
```



## 附录：
ffmpeg带上 x265 库遇到的问题，加了`--extra-ldflags="-L${OTHER_LIB}/lib -lm -lstdc++"`都不管用。
```output
arm-linux-gcc -D_ISOC99_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600 -I/home/schips/ffmpeg_x265_try/install/__all_without_ffmpeg/include -march=armv5te -std=c11 -fomit-frame-pointer -marm -pthread -c -o /tmp/ffconf.qfzvUKnH/test.o /tmp/ffconf.qfzvUKnH/test.c
arm-linux-gcc -L/home/schips/ffmpeg_x265_try/install/__all_without_ffmpeg/lib -march=armv5te -Wl,--as-needed -Wl,-z,noexecstack -o /tmp/ffconf.qfzvUKnH/test /tmp/ffconf.qfzvUKnH/test.o
/tmp/ffconf.qfzvUKnH/test.o: In function `foo':
test.c:(.text+0xa0): undefined reference to `cabs'
collect2: error: ld returned 1 exit status
check_complexfunc cexp 1
test_ld cc
test_cc
BEGIN /tmp/ffconf.qfzvUKnH/test.c
    1   #include <complex.h>
    2   #include <math.h>
    3   float foo(complex float f, complex float g) { return cexp(f * I); }
    4   int main(void){ return (int) foo; }
END /tmp/ffconf.qfzvUKnH/test.c
arm-linux-gcc -D_ISOC99_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600 -I/home/schips/ffmpeg_x265_try/install/__all_without_ffmpeg/include -march=armv5te -std=c11 -fomit-frame-pointer -marm -pthread -c -o /tmp/ffconf.qfzvUKnH/test.o /tmp/ffconf.qfzvUKnH/test.c
arm-linux-gcc -L/home/schips/ffmpeg_x265_try/install/__all_without_ffmpeg/lib -march=armv5te -Wl,--as-needed -Wl,-z,noexecstack -o /tmp/ffconf.qfzvUKnH/test /tmp/ffconf.qfzvUKnH/test.o
/tmp/ffconf.qfzvUKnH/test.o: In function `foo':
test.c:(.text+0xa8): undefined reference to `cexp'
collect2: error: ld returned 1 exit status
require_pkg_config libx265 x265 x265.h x265_api_get
check_pkg_config libx265 x265 x265.h x265_api_get
test_pkg_config libx265 x265 x265.h x265_api_get
false --exists --print-errors x265
ERROR: x265 not found using pkg-config

```

