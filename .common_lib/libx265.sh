export X265=x265_3.2
export X265_OUTPUT_PATH=${OUTPUT_PATH}/x265

## for others
X265_FILE_NAME=${X265}.tar.gz
X265_ARCH_PATH=$ROOT_DIR/libx265/compressed/${X265_FILE_NAME}

### X265
get_x265 () {
    if [ -f "$X265_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $X265_ARCH_PATH $ARCHIVE_PATH/$X265_FILE_NAME
        return
    else
        tget http://download.videolan.org/videolan/x265/${X265}.tar.gz
    fi
}

mk_x265() {
    cd ${BASE}/source/x265*/build
    mkdir arm-x265
    cd arm-x265
    # 获取 工具链所在位置
    GCC_FULL_PATH=`whereis ${BUILD_HOST_}gcc | awk -F: '{ print $2 }' | awk '{print $1}'` # 防止多个结果
    CROSS_PATH=`dirname ${GCC_FULL_PATH}`
    touch crosscompile.cmake
    #echo "set(CROSS_COMPILE_ARM 1)" > crosscompile.cmake
    echo "set(CMAKE_SYSTEM_NAME Linux)" > crosscompile.cmake
    echo "set(CMAKE_SYSTEM_PROCESSOR arm)" >> crosscompile.cmake
    echo "" >> crosscompile.cmake
    echo "# specify the cross compiler" >> crosscompile.cmake
    echo "set(CMAKE_C_COMPILER ${CROSS_PATH}/${BUILD_HOST}-gcc)" >> crosscompile.cmake
    echo "set(CMAKE_CXX_COMPILER ${CROSS_PATH}/${BUILD_HOST}-g++)" >> crosscompile.cmake
    echo "set(CMAKE_SHARED_LINKER_FLAGS \"-ldl \${CMAKE_SHARED_LINKER_FLAGS}\")" >> crosscompile.cmake
    echo "" >> crosscompile.cmake
    echo "# specify the target environment" >> crosscompile.cmake
    echo "SET(CMAKE_FIND_ROOT_PATH  ${CROSS_PATH})" >> crosscompile.cmake

    # 编译安装
    cmake -DCMAKE_TOOLCHAIN_FILE=crosscompile.cmake -G "Unix Makefiles" \
    -DCMAKE_C_FLAGS="-fPIC ${CMAKE_C_FLAGS}" -DCMAKE_CXX_FLAGS="-fPIC ${CMAKE_CXX_FLAGS}" \
    -DCMAKE_SHARED_LINKER_FLAGS="-ldl ${CMAKE_SHARED_LINKER_FLAGS}"  \
    -DCMAKE_INSTALL_PREFIX=${X265_OUTPUT_PATH} ../../source || return 1
    make -j8
    make install
}

function make_x265 () {
    get_x265
    tar_package
    mk_x265
}
