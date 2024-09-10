ZLIB=zlib
export CONFIG_ZLIB_VERSION=1.2.11
export ZLIB_VERSION=${ZLIB}-${CONFIG_ZLIB_VERSION}

export ZLIB_OUTPUT_PATH=${OUTPUT_PATH}/${ZLIB}

## for others
export ZLIB_FILE_NAME=${ZLIB_VERSION}.tar.gz
export ZLIB_ARCH_PATH=$ROOT_DIR/zlib/compressed/${ZLIB_FILE_NAME}

### ZLIB
function get_zlib () {
    export ZLIB_VERSION=${ZLIB}-${CONFIG_ZLIB_VERSION}
    export ZLIB_FILE_NAME=${ZLIB_VERSION}.tar.gz
    export ZLIB_ARCH_PATH=$ROOT_DIR/zlib/compressed/${ZLIB_FILE_NAME}

    if [ -f "$ZLIB_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $ZLIB_ARCH_PATH $ARCHIVE_PATH/$ZLIB_FILE_NAME
        return
    else
        tget https://www.zlib.net/${ZLIB_VERSION}.tar.gz
    fi
}

function mk_zlib () {
    export ZLIB_VERSION=${ZLIB}-${CONFIG_ZLIB_VERSION}
bash <<EOF
    cd ${CODE_PATH}/${ZLIB_VERSION}
    CC=${_CC} ./configure --prefix=${ZLIB_OUTPUT_PATH}
    make clean
    make $MKTHD && make install
EOF
}

function make_zlib () {
    export ZLIB_VERSION=${ZLIB}-${CONFIG_ZLIB_VERSION}
    get_zlib
    tar_package       || return 1
    mk_zlib
}
