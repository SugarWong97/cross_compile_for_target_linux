MBEDTLS=mbedtls
export CONFIG_MBEDTLS_VERSION2=2.16.12
export MBEDTLS_VERSION=${MBEDTLS}-${CONFIG_MBEDTLS_VERSION2}

export MBEDTLS_OUTPUT_PATH=${OUTPUT_PATH}/${MBEDTLS}

## for others
export MBEDTLS_FILE_NAME=${MBEDTLS_VERSION}.tar.gz
export MBEDTLS_ARCH_PATH=$ROOT_DIR/mbedtls/compressed/${MBEDTLS_FILE_NAME}


function _sync_export_var_mbedtls_v2()
{
    export MBEDTLS_VERSION=${MBEDTLS}-${CONFIG_MBEDTLS_VERSION2}
    export MBEDTLS_FILE_NAME=${MBEDTLS_VERSION}.tar.gz
    export MBEDTLS_ARCH_PATH=$ROOT_DIR/mbedtls/compressed/${MBEDTLS_FILE_NAME}
}

function get_mbedtls_v2 () {
    _sync_export_var_mbedtls_v2
    if [ -f "$MBEDTLS_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $MBEDTLS_ARCH_PATH $ARCHIVE_PATH/$MBEDTLS_FILE_NAME
        return
    else
        ##   https://github.com/Mbed-TLS/mbedtls/releases/download/mbedtls-3.6.3/mbedtls-3.6.3.tar.bz2
        #tget https://github.com/Mbed-TLS/mbedtls/releases/download/${MBEDTLS_VERSION3}/${MBEDTLS_FILE_NAME}
        ##   https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/v2.16.12.tar.gz
        tget_and_rename https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/v${CONFIG_MBEDTLS_VERSION2}.tar.gz $MBEDTLS_FILE_NAME
    fi
}

function mk_mbedtls_v2 () {
    _sync_export_var_mbedtls_v2
bash <<EOF
    cd ${CODE_PATH}/${MBEDTLS_VERSION}

    rm .build -rf; mkdir .build -p ; cd .build
    cmake .. \
         -DCMAKE_SYSTEM_NAME=Linux \
         -DCMAKE_INSTALL_PREFIX=${MBEDTLS_OUTPUT_PATH} \
         -DCMAKE_C_COMPILER=${_CC}



    # 未使用的编译选项
    ##编译选项
    ##COMPILER_FLAGS="-march=armv7-a -marm -mfpu=neon -mfloat-abi=hard -fPIC "
    ##依赖库位置
    ##COMPILER_LIB=$(pwd)/../../target_cross
    ##cmake .. -DCMAKE_SYSROOT=$QL_SYSROOT  -DCMAKE_C_FLAGS="$COMPILER_FLAGS"  -DCMAKE_PREFIX_PATH="$COMPILER_LIB" 




    make clean
    make $MKTHD && make install
EOF
}

function make_mbedtls_v2 () {
    _sync_export_var_mbedtls_v2
    get_mbedtls_v2
    tar_package       || return 1
    mk_mbedtls_v2
}

