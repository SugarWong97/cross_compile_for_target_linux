##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Mon 02 Sep 2019 08:05:53 PM HKT
##
#!/bin/sh
BASE=`pwd`
BUILD_HOST=arm-hisiv500-linux
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
    # 每次还原 CMakeLists 文件
    if [ ! -f CMakeLists.txt.old ];then
        # 不存在就创建
        cp CMakeLists.txt  CMakeLists.txt.old
    else
        # 存在就还原
        cp CMakeLists.txt.old  CMakeLists.txt
    fi
    # 获取 工具链所在位置 下面的操作为的是在 CMakeLists.txt 中插入下面内容
        #set( CMAKE_SYSTEM_NAME Linux  )
        #set( CMAKE_SYSTEM_PROCESSOR ARM  )
        #set( CMAKE_C_COMPILER "/opt/hisi-linux/x86-arm/arm-hisiv500-linux/target/bin/arm-hisiv500-linux-gcc" )
        #set( CMAKE_CXX_COMPILER "/opt/hisi-linux/x86-arm/arm-hisiv500-linux/target/bin/arm-hisiv500-linux-g++" )
        #set( CMAKE_FIND_ROOT_PATH "/opt/hisi-linux/x86-arm/arm-hisiv500-linux/target/bin/" )
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
#make_x265
prepare_other_lib
make_ffmpeg

exit $?
    --enable-ffserver \
    --enable-libx265 \
