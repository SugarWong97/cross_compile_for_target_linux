#!/bin/bash

export FFMPEG=ffmpeg
export CONFIG_FFMPEG_VERSION=4.2.10
#export CONFIG_FFMPEG_VERSION=7.0
export FFMPEG_VERSION=${FFMPEG}-${CONFIG_FFMPEG_VERSION}

# 通过y/n来配置ffmpeg是否启用 Libx264, Libx265（默认启用）
export USING_X264_FOR_FFMPEG
export USING_X265_FOR_FFMPEG

## for others
export FFMPEG_FILE_NAME=${FFMPEG_VERSION}.tar.bz2
export FFMPEG_ARCH_PATH=$ROOT_DIR/ffmpeg/compressed/${FFMPEG_FILE_NAME}

# LIBX264 Config(启用libx264时有效)
### 通过y/n来配置libx264是否启用ASM（默认禁用）
#export USING_X264_ASM=n
### 通过y/n来配置libx264是否启用OPENCL（默认禁用）
#export USING_X264_OPENCL=n

export FFMPEG_OUTPUT_PATH=${OUTPUT_PATH}/ffmpeg
#export X264_OUTPUT_PATH=${OUTPUT_PATH}/ffmpeg
#export X265_OUTPUT_PATH=${OUTPUT_PATH}/ffmpeg

export FFMPEG_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/ffmpeg
#export X264_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/ffmpeg
#export X265_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/ffmpeg

set_ffmpeg()
{
    if [ "$USING_X264_FOR_FFMPEG" = "n" ];then
        export X264_FOR_FFMPEG="no"
    else
        export X264_FOR_FFMPEG="yes"
    fi

    if [ "$USING_X265_FOR_FFMPEG" = "n" ];then
        export X265_FOR_FFMPEG="no"
    else
        export X265_FOR_FFMPEG="yes"
    fi

    export FFMPEG_VERSION=${FFMPEG}-${CONFIG_FFMPEG_VERSION}
}

get_ffmpeg () {
    set_ffmpeg
    if [ "$X264_FOR_FFMPEG" = "yes" ];then
        get_x264
    fi
    if [ "$X265_FOR_FFMPEG" = "yes" ];then
        get_x265
    fi
    tget_package_from_arch  $FFMPEG_ARCH_PATH $ARCHIVE_PATH/$FFMPEG_FILE_NAME  https://ffmpeg.org/releases/$FFMPEG_FILE_NAME
}

function gen_ffmpeg_make_sh () {
    local for_host="$1"
    local enable_for_x264=""
    local enable_for_x265=""
    if [ "$X264_FOR_FFMPEG" = "yes" ];then
        enable_for_x264="--enable-libx264"
    fi
    if [ "$X265_FOR_FFMPEG" = "yes" ];then
        enable_for_x265="--enable-libx265"
    fi
    local config_args_add=""

    local build_dir=""
    local output_dir=""

    local env_add=""
    local config_args_add=""

    if [ -z "$for_host" ];then
        read -r -d '' env_add <<- EOF
        MYPKGCONFIG_x264=${X264_OUTPUT_PATH}/lib/pkgconfig/
        MYPKGCONFIG_x265=${X265_OUTPUT_PATH}/lib/pkgconfig/
        export PKG_CONFIG_PATH=\${MYPKGCONFIG_x264}:\${MYPKGCONFIG_x265}:\$PKG_CONFIG_PATH
EOF

        read -r -d '' config_args_add <<- EOF
        --prefix=${FFMPEG_OUTPUT_PATH} \
        --enable-cross-compile \
        --cross-prefix=${BUILD_HOST_} \
        --cc=${_CC}\
        --extra-cflags="-I${X264_OUTPUT_PATH}/include -I${X265_OUTPUT_PATH}/include" \
        --extra-ldflags="-L${X264_OUTPUT_PATH}/lib -L${X265_OUTPUT_PATH}/lib" \
        --arch=${BUILD_ARCH}
EOF
    else
        read -r -d '' env_add <<- EOF
        MYPKGCONFIG_x264=${X264_OUTPUT_PATH_HOST}/lib/pkgconfig/
        MYPKGCONFIG_x265=${X265_OUTPUT_PATH_HOST}/lib/pkgconfig/
        export PKG_CONFIG_PATH=\${MYPKGCONFIG_x264}:\${MYPKGCONFIG_x265}:\$PKG_CONFIG_PATH
EOF

        read -r -d '' config_args_add <<- EOF
        --prefix=${FFMPEG_OUTPUT_PATH_HOST} \
        --extra-cflags="-I${X264_OUTPUT_PATH_HOST}/include -I${X265_OUTPUT_PATH_HOST}/include" \
        --extra-ldflags="-L${X264_OUTPUT_PATH_HOST}/lib -L${X265_OUTPUT_PATH_HOST}/lib "
EOF
    fi
    cat<<-EOF
    $env_add
    ./configure \
    --target-os=linux $config_args_add \
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
    --pkg-config="pkg-config --static"
EOF
    #--enable-ffserver \
}
function gen_ffmpeg_make_sh_host () {
    gen_ffmpeg_make_sh y
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
    get_ffmpeg  || return 1
    tar_package || return 1
    if [ "$X264_FOR_FFMPEG" = "yes" ];then
        make_x264 || return 1
    fi
    if [ "$X265_FOR_FFMPEG" = "yes" ];then
        make_x265 || return 1
    fi
    mk_ffmpeg
}

function mk_ffmpeg_host() {

    cd ${CODE_PATH}/${FFMPEG_VERSION}
    gen_ffmpeg_make_sh_host > $tmp_config
    bash ./$tmp_config || return 1
    make clean
    make $MKTHD && make install
}

function make_ffmpeg_host ()
{
    require cmake || return 1
    get_ffmpeg  || return 1
    tar_package || return 1
    if [ "$X264_FOR_FFMPEG" = "yes" ];then
        make_x264_host || return 1
    fi
    if [ "$X265_FOR_FFMPEG" = "yes" ];then
        make_x265_host || return 1
    fi
    mk_ffmpeg_host
}

