#!/bin/bash

export FFMPEG=ffmpeg
#export FFMPEG_VERSION=${FFMPEG}-4.0.1
export FFMPEG_VERSION=${FFMPEG}-7.0

# 是否启用 Libx264, Libx265
## 默认启用，禁用时设y即可
export DISABLE_X264_FOR_FFMPEG
export DISABLE_X265_FOR_FFMPEG

# LIBX264 Config(启用libx264时有效)
export DISABLE_X264_ASM=n
export DISABLE_X264_OPENCL=n


if [ -z $DISABLE_X264_FOR_FFMPEG ];then
export USING_X264_FOR_FFMPEG=yes
fi

if [ -z $USING_X265_FOR_FFMPEG ];then
export USING_X265_FOR_FFMPEG=yes
fi

X264_OUTPUT_PATH=${OUTPUT_PATH}/x264
X265_OUTPUT_PATH=${OUTPUT_PATH}/x265
FFMP_OUTPUT_PATH=${OUTPUT_PATH}/ffmpeg

download_package_for_ffmpeg () {
    if [ ! -z "$USING_X264_FOR_FFMPEG" ];then
        get_x264
    fi
    if [ ! -z "$USING_X265_FOR_FFMPEG" ];then
        get_x265
    fi
    tget https://ffmpeg.org//releases/${FFMPEG_VERSION}.tar.bz2
}

## OTHER_LIB=${OUTPUT_PATH}/__all_without_ffmpeg
## prepare_other_lib_for_ffmpeg () {
##     # 这一个是针对 ffmpeg 方便管理外部库使用的
##     # 核心思想是把 所有的库都放到一起，再让 ffmpeg ld的时候在这里找（而不是添加多行） --extra-cflags="-I${X264_DIR}/include -I${xxx}/include" \
##     cd ${BASE}/install/
##     rm ${OTHER_LIB} -rf
##     ls > /tmp/list.txt
##     mkdir ${OTHER_LIB} -p
##     for sub_dir in `cat /tmp/list.txt`
##     do
##         cp ${sub_dir}/* ${OTHER_LIB} -r -v
##     done
##     rm -rf /tmp/list.txt
## }
function gen_ffmpeg_make_sh () {
    local enable_for_x264=""
    local enable_for_x265=""
    if [ ! -z "$USING_X264_FOR_FFMPEG" ];then
        enable_for_x264="--enable-libx264"
    fi
    if [ ! -z "$USING_X265_FOR_FFMPEG" ];then
        enable_for_x265="--enable-libx265"
    fi
cat<<EOF
    MYPKGCONFIG_x264=${BASE}/install/x264/lib/pkgconfig/
    MYPKGCONFIG_x265=${BASE}/install/x265/lib/pkgconfig/
    export PKG_CONFIG_PATH=\${MYPKGCONFIG_x264}:\${MYPKGCONFIG_x265}:\$PKG_CONFIG_PATH
    ./configure \
    --enable-cross-compile \
    --cross-prefix=${BUILD_HOST_} \
    --target-os=linux \
    --cc=${_CC} \
    --arch=${BUILD_ARCH} \
    --prefix=${FFMP_OUTPUT_PATH} \
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
    --disable-stripping ${enable_for_x264} ${enable_for_x265} \
    --pkg-config="pkg-config --static" \
    --extra-cflags="-I${X264_OUTPUT_PATH}/include -I${X265_OUTPUT_PATH}/include" \
    --extra-ldflags="-L${X264_OUTPUT_PATH}/lib -L${X265_OUTPUT_PATH}/lib "
EOF
    #--enable-ffserver \
}

function mk_ffmpeg() {

    cd ${CODE_PATH}/${FFMPEG_VERSION}
    gen_ffmpeg_make_sh > $tmp_config
    bash ./$tmp_config || return 1
    make clean
    make $MKTHD && make install
}

function make_ffmpeg ()
{
    require cmake || return 1
    download_package_for_ffmpeg  || return 1
    tar_package || return 1
    if [ ! -z "$USING_X264_FOR_FFMPEG" ];then
        make_x264 || return 1
    fi
    if [ ! -z "$USING_X265_FOR_FFMPEG" ];then
        make_x265 || return 1
    fi
    mk_ffmpeg
}

