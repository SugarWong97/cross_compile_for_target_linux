ZLMEDIAKIT=ZLMediaKit
#export CONFIG_ZLMEDIAKIT_VERSION=7.0
export CONFIG_ZLMEDIAKIT_VERSION=master
export ZLMEDIAKIT_VERSION=${ZLMEDIAKIT}-${CONFIG_ZLMEDIAKIT_VERSION}

export ZLMEDIAKIT_URL=https://github.com/ZLMediaKit/ZLMediaKit
#export ZLMEDIAKIT_URL=https://gitee.com/xia-chu/ZLMediaKit

export ZLMEDIAKIT_OUTPUT_PATH=${OUTPUT_PATH}/${ZLMEDIAKIT}
export ZLMEDIAKIT_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${ZLMEDIAKIT}


# libx264 Config(启用ffmpeg时有效)
### 通过y/n来配置libx264是否启用ASM（默认禁用）
#export USING_X264_ASM=n
### 通过y/n来配置libx264是否启用OPENCL（默认禁用）
#export USING_X264_OPENCL=n



# 是否使用外部组件（默认禁用，写y启用）
## OpenSSL
export USING_OPENSSL_FOR_ZLMEDIAKIT=""
## FFmpeg
export USING_FFMPEG_FOR_ZLMEDIAKIT=""


export OPENSSL_FOR_ZLMEDIAKIT=""
export FFMPEG_FOR_ZLMEDIAKIT=""

function _sync_export_var_zlmediakit()
{
    if [ "$USING_OPENSSL_FOR_ZLMEDIAKIT" = "y" ];then
        export OPENSSL_FOR_ZLMEDIAKIT="yes"
    else
        export OPENSSL_FOR_ZLMEDIAKIT="no"
    fi

    if [ "$USING_FFMPEG_FOR_ZLMEDIAKIT" = "y" ];then
        export FFMPEG_FOR_ZLMEDIAKIT="yes"
        export USING_X264_FOR_FFMPEG="y"
        export USING_X265_FOR_FFMPEG="n"
    else
        export FFMPEG_FOR_ZLMEDIAKIT="no"
    fi
}

function get_zlmediakit () {
    _sync_export_var_zlmediakit

    if [ "$OPENSSL_FOR_ZLMEDIAKIT" = "yes" ];then
        get_ssl
    fi
    if [ "$FFMPEG_FOR_ZLMEDIAKIT" = "yes" ];then
        get_ffmpeg
    fi

    tgit_with_bracnch_and_submod  $ZLMEDIAKIT_URL $CONFIG_ZLMEDIAKIT_VERSION
}

function mk_zlmediakit () {
    local build_for_host="$1"

    local openssl_cmake_part_arg="-DENABLE_OPENSSL=off"
    local build_for_host_cmake_part_arg=""
    local pkg_config_path_add=""
    local output_cmake_part_arg=""

    _sync_export_var_zlmediakit

    cd ${CODE_PATH}/${ZLMEDIAKIT_VERSION} || return 1

    if [ "$OPENSSL_FOR_ZLMEDIAKIT" = "yes" ];then
        pkg_config_path_add="$OPENSSL_OUTPUT_PATH/lib/pkgconfig:$pkg_config_path_add";
    fi

    if [ "$FFMPEG_FOR_ZLMEDIAKIT" = "yes" ];then
        pkg_config_path_add="$FFMPEG_OUTPUT_PATH/lib/pkgconfig:$pkg_config_path_add";
    fi

    if [  "$build_for_host" == 'y' ];then
        build_for_host_cmake_part_arg="-DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++"
        output_cmake_part_arg="-D CMAKE_INSTALL_PREFIX=${ZLMEDIAKIT_OUTPUT_PATH_HOST}"
    else
        build_for_host_cmake_part_arg=" -DCMAKE_C_COMPILER=${BUILD_HOST_}gcc -DCMAKE_CXX_COMPILER=${BUILD_HOST_}g++"
        output_cmake_part_arg="-D CMAKE_INSTALL_PREFIX=${ZLMEDIAKIT_OUTPUT_PATH}"
    fi


cat <<EOF > $tmp_config
    export PKG_CONFIG_PATH="$pkg_config_path_add:\$PKG_CONFIG_PATH"

    rm build -rf
    mkdir -p build
    cd build
    cmake ..  $openssl_cmake_part_arg $build_for_host_cmake_part_arg \
        $output_cmake_part_arg \
        -DCMAKE_BUILD_TYPE=Release  \
        -DENABLE_HLS=off            \
        -DENABLE_HLS_FMP4=off       \
        -DENABLE_MYSQL=off          \
        -DENABLE_WEBRTC=off         \
        -DDISABLE_REPORT=on         \
        -DENABLE_MP4=on             \
        -DENABLE_SRT=off            \
        -DENABLE_SERVER_LIB=on      \
        -DENABLE_API=on             \
        -DENABLE_CXX_API=on

    make clean
    make $MKTHD && make install

#option(ENABLE_API_STATIC_LIB "Enable mk_api static lib" OFF)
#option(ENABLE_ASAN "Enable Address Sanitize" OFF)
#option(ENABLE_CXX_API "Enable C++ API SDK" OFF)
#option(ENABLE_FAAC "Enable FAAC" OFF)
#option(ENABLE_MSVC_MT "Enable MSVC Mt/Mtd lib" ON)
#option(ENABLE_PLAYER "Enable Player" ON)
#option(ENABLE_RTPPROXY "Enable RTPPROXY" ON)
#option(ENABLE_SERVER "Enable Server" ON)
#option(ENABLE_SERVER_LIB "Enable server as android static library" OFF)
#option(ENABLE_SRT "Enable SRT" ON)
#option(ENABLE_TESTS "Enable Tests" ON)
#option(ENABLE_SCTP "Enable SCTP" ON)
#option(ENABLE_WEPOLL "Enable wepoll" ON)
#option(USE_SOLUTION_FOLDERS "Enable solution dir supported" ON)
EOF
    bash $tmp_config
}

function make_zlmediakit () {
    _sync_export_var_zlmediakit
    get_zlmediakit    || return 1
    tar_package       || return 1

    if [ "$OPENSSL_FOR_ZLMEDIAKIT" = "yes" ];then
        make_ssl || return 1
    fi
    if [ "$FFMPEG_FOR_ZLMEDIAKIT" = "yes" ];then
        make_ffmpeg || return 1
    fi
    mk_zlmediakit
}

function make_zlmediakit_host () {
    _sync_export_var_zlmediakit
    get_zlmediakit    || return 1
    tar_package       || return 1

    if [ "$OPENSSL_FOR_ZLMEDIAKIT" = "yes" ];then
        make_ssl_host || return 1
    fi
    if [ "$FFMPEG_FOR_ZLMEDIAKIT" = "yes" ];then
        make_ffmpeg_host || return 1
    fi
    mk_zlmediakit  y
}

