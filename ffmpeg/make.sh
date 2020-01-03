##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Mon 02 Sep 2019 08:05:53 PM HKT
##
#!/bin/sh
BASE=`pwd`
OUTPUT_PATH=${BASE}/install

X264_DIR=${OUTPUT_PATH}/x264
BUILD_HOST=arm-linux

make_dirs () {
    #为了方便管理，创建有关的目录
    cd ${BASE} && mkdir compressed install source -p
}

download_package () {
    cd ${BASE}/compressed
    wget http://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20171212-2245.tar.bz2
    #wget http://ffmpeg.org/releases/ffmpeg-3.4.1.tar.bz2

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
    --extra-cflags=-I${X264_DIR}/include \
    --extra-ldflags=-L${X264_DIR}/lib
    make clean && make -j4 && make install
}
echo "Using ${BUILD_HOST}-gcc"
make_dirs
download_package
tar_package
make_x264
make_ffmpeg


