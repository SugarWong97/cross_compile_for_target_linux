export ZLIB=zlib-1.2.11


## for others
ZLIB_FILE_NAME=${ZLIB}.tar.gz
ZLIB_ARCH_PATH=$ROOT_DIR/zlib/compressed/${ZLIB_FILE_NAME}

### ZLIB
function get_zlib () {
    if [ -f "$ZLIB_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $ZLIB_ARCH_PATH $ARCHIVE_PATH/$ZLIB_FILE_NAME
        return
    else
        tget https://www.zlib.net/${ZLIB}.tar.gz
    fi
}

function mk_zlib () {
bash <<EOF
    cd ${CODE_PATH}/${ZLIB}
    CC=${_CC} ./configure --prefix=${OUTPUT_PATH}/${ZLIB}
    make clean
    make $MKTHD && make install
EOF
}

function make_zlib () {
    get_zlib
    tar_package       || return 1
    mk_zlib
}
