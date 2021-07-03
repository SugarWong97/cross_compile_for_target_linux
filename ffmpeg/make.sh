##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Mon 02 Sep 2019 08:05:53 PM HKT
##
#!/bin/sh
source ../.common

OTHER_LIB=${OUTPUT_PATH}/__all_without_ffmpeg
X264_OUTPUT_PATH=${OUTPUT_PATH}/x264
X265_OUTPUT_PATH=${OUTPUT_PATH}/x265
FFMP_OUTPUT_PATH=${OUTPUT_PATH}/ffmpeg

download_package () {
    cd ${BASE}/compressed
    tget http://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20171212-2245.tar.bz2
    tget http://ffmpeg.org/releases/ffmpeg-4.0.1.tar.bz2
    tget http://download.videolan.org/videolan/x265/x265_3.2.tar.gz
}

function make_x264() {
function _make_sh () {
cat<<EOF
    CC=${_CC} \
    ./configure \
    --host=${BUILD_HOST} \
    --enable-shared \
    --enable-static \
    --enable-pic \
    --prefix=${X264_OUTPUT_PATH} \
    --cross-prefix=${BUILD_HOST_} \
    --disable-asm 
EOF
}
    cd ${BASE}/source/x264*

    _make_sh > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make $MKTHD && make install
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
    GCC_FULL_PATH=`whereis ${_CC} | awk -F: '{ print $2 }' | awk '{print $1}'` # 防止多个结果
    GCC_DIR=`dirname ${GCC_FULL_PATH}/`
    sed -i "1i\set( CMAKE_SYSTEM_NAME Linux  )"                         CMakeLists.txt
    sed -i "2a\set( CMAKE_SYSTEM_PROCESSOR ARM  )"                      CMakeLists.txt
    sed -i "2a\set( CMAKE_C_COMPILER ${GCC_DIR}/${_CC}  )"              CMakeLists.txt
    sed -i "2a\set( CMAKE_CXX_COMPILER ${GCC_DIR}/${_CPP}  )"           CMakeLists.txt
    sed -i "2a\set( CMAKE_FIND_ROOT_PATH ${GCC_DIR} )"                  CMakeLists.txt
    cmake ../source
    # 指定安装路径
    sed -i "1i\set( CMAKE_INSTALL_PREFIX "${X265_OUTPUT_PATH}"  )"     cmake_install.cmake
    make clean
    make $MKTHD && make install
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

function make_ffmpeg() {
function _make_sh () {
cat<<EOF
    MYPKGCONFIG=${BASE}/install/x265/lib/pkgconfig/
    export PKG_CONFIG_PATH=${MYPKGCONFIG}:$PKG_CONFIG_PATH
    ./configure \
    --cross-prefix=${BUILD_HOST_} \
    --enable-cross-compile \
    --target-os=linux \
    --cc=${_CC} \
    --arch=arm \
    --prefix=${FFMP_OUTPUT_PATH} \
    --enable-shared \
    --enable-static \
    --pkg-config="pkg-config --static" \
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
    --enable-libx265 \
    --extra-cflags=-I${OTHER_LIB}/include \
    --extra-ldflags=-L${OTHER_LIB}/lib
EOF
    #--enable-ffserver \
}
    MYPKGCONFIG=${X265_OUTPUT_PATH}/lib/pkgconfig/
    export PKG_CONFIG_PATH=${MYPKGCONFIG}:$PKG_CONFIG_PATH

    cd ${BASE}/source/ffmpeg*
    _make_sh > $tmp_config
    source ./$tmp_config || return 1
    make clean
    make $MKTHD && make install
}

function make_build ()
{
    require cmake || return 1
    download_package  || return 1
    #tar_package || return 1
    #make_x264 || return 1
    #make_x265 || return 1
    #prepare_other_lib || return 1
    make_ffmpeg
}

make_build || echo "Err"
