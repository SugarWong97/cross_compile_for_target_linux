ZLIB=zlib
export CONFIG_ZLIB_VERSION=1.2.11
export ZLIB_VERSION=${ZLIB}-${CONFIG_ZLIB_VERSION}

export ZLIB_OUTPUT_PATH=${OUTPUT_PATH}/${ZLIB}

## for others
export ZLIB_FILE_NAME=${ZLIB_VERSION}.tar.gz
export ZLIB_ARCH_PATH=$ROOT_DIR/zlib/compressed/${ZLIB_FILE_NAME}

function _sync_export_var_zlib()
{
    export ZLIB_VERSION=${ZLIB}-${CONFIG_ZLIB_VERSION}
    export ZLIB_FILE_NAME=${ZLIB_VERSION}.tar.gz
    export ZLIB_ARCH_PATH=$ROOT_DIR/zlib/compressed/${ZLIB_FILE_NAME}
}

function get_zlib () {
    _sync_export_var_zlib
    tget_package_from_arch  $ZLIB_ARCH_PATH $ARCHIVE_PATH/$ZLIB_FILE_NAME  https://www.zlib.net/${ZLIB_VERSION}.tar.gz
}

function mk_zlib () {
    _sync_export_var_zlib
bash <<EOF
    cd ${CODE_PATH}/${ZLIB_VERSION}
    CC=${_CC} ./configure --prefix=${ZLIB_OUTPUT_PATH}
    make clean
    make $MKTHD && make install
EOF
}

function make_zlib () {
    _sync_export_var_zlib
    get_zlib
    tar_package       || return 1
    mk_zlib
}
