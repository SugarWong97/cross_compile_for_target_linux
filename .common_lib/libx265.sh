export X265=x265
export CONFIG_X265_VERSION=3.5
export X265_VERSION=x265_${CONFIG_X265_VERSION}
export X265_OUTPUT_PATH=${OUTPUT_PATH}/x265
export X265_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/x265

## for others
export X265_FILE_NAME=${X265_VERSION}.tar.gz
export X265_ARCH_PATH=$ROOT_DIR/libx265/compressed/${X265_FILE_NAME}

function _sync_export_var_x265()
{
    export X265_VERSION=x265_${CONFIG_X265_VERSION}
    export X265_FILE_NAME=${X265_VERSION}.tar.gz
    export X265_ARCH_PATH=$ROOT_DIR/libx265/compressed/${X265_FILE_NAME}
}

get_x265 () {
    _sync_export_var_x265
    tget_package_from_arch $X265_ARCH_PATH  $ARCHIVE_PATH/$X265_FILE_NAME http://download.videolan.org/videolan/x265/${X265_VERSION}.tar.gz
}

mk_x265() {
    local for_host="$1"

    local build_dir=""
    local output_dir=""
    if [ -z "$for_host" ];then
        build_dir="arm-x265"
        output_dir=${X265_OUTPUT_PATH}
    else
        build_dir="host-x265"
        output_dir=${X265_OUTPUT_PATH_HOST}
    fi

    cd ${CODE_PATH}/${X265_VERSION}/build
    rm -rf $build_dir
    mkdir -p $build_dir
    cd $build_dir

    # 获取 工具链所在位置
    GCC_FULL_PATH=`whereis ${BUILD_HOST_}gcc | awk -F: '{ print $2 }' | awk '{print $1}'` # 防止多个结果
    CROSS_PATH=`dirname ${GCC_FULL_PATH}`
    echo "" >  crosscompile.cmake

    if [ -z "$for_host" ];then
        echo "set(CMAKE_SYSTEM_NAME Linux)" >> crosscompile.cmake
        echo "set(CMAKE_SYSTEM_PROCESSOR armv6)" >> crosscompile.cmake
        echo "" >> crosscompile.cmake
        echo "# specify the cross compiler" >> crosscompile.cmake
        echo "set(CMAKE_C_COMPILER ${CROSS_PATH}/${BUILD_HOST}-gcc)" >> crosscompile.cmake
        echo "set(CMAKE_CXX_COMPILER ${CROSS_PATH}/${BUILD_HOST}-g++)" >> crosscompile.cmake
        echo "set(CMAKE_SHARED_LINKER_FLAGS \"-ldl \${CMAKE_SHARED_LINKER_FLAGS}\")" >> crosscompile.cmake
        echo "" >> crosscompile.cmake
        echo "# specify the target environment" >> crosscompile.cmake
        echo "SET(CMAKE_FIND_ROOT_PATH  ${CROSS_PATH})" >> crosscompile.cmake
    else
        echo "set(CMAKE_SHARED_LINKER_FLAGS \"-ldl \${CMAKE_SHARED_LINKER_FLAGS}\")" >> crosscompile.cmake
    fi

    # 编译安装
    cmake -DCMAKE_TOOLCHAIN_FILE=crosscompile.cmake -G "Unix Makefiles" \
    -DCMAKE_C_FLAGS="-fPIC ${CMAKE_C_FLAGS}" -DCMAKE_CXX_FLAGS="-fPIC ${CMAKE_CXX_FLAGS}" \
    -DCMAKE_SHARED_LINKER_FLAGS="-ldl ${CMAKE_SHARED_LINKER_FLAGS}"  \
    -DCMAKE_INSTALL_PREFIX=${output_dir} ../../source || return 1
    make $MKTHD && make install
}

mk_x265_host () {
    mk_x265 y
}

function make_x265 () {
    _sync_export_var_x265
    get_x265
    tar_package
    mk_x265
}

function make_x265_host () {
    _sync_export_var_x265
    get_x265
    tar_package
    mk_x265_host
}

