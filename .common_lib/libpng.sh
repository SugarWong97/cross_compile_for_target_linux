LIBPNG_VERSION=1.2.59

LIBPNG=libpng-${LIBPNG_VERSION}

## for others
export LIBPNG_FILE_NAME=${LIBPNG}.tar.gz
export LIBPNG_ARCH_PATH=$ROOT_DIR/libpng/compressed/${LIBPNG_FILE_NAME}

function get_libpng () {
    export LIBPNG_FILE_NAME=${LIBPNG}.tar.gz
    export LIBPNG_ARCH_PATH=$ROOT_DIR/libpng/compressed/${LIBPNG_FILE_NAME}
    if [ -f "$ZLIB_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $LIBPNG_ARCH_PATH $ARCHIVE_PATH/$LIBPNG_FILE_NAME
        return
    else
        tget https://udomain.dl.sourceforge.net/project/libpng/libpng12/${LIBPNG_VERSION}/libpng-${LIBPNG_VERSION}.tar.gz
    fi
}

download_png () {
    get_libpng
    get_zlib
}

function mk_png () {
function _make_sh () {
cat<<EOF
    ./configure --host=${BUILD_HOST} \
        --enable-shared \
        --enable-static \
        --prefix=${OUTPUT_PATH}/libpng \
        LDFLAGS="-L${OUTPUT_PATH}/${ZLIB}/lib" \
        CPPFLAGS="-I${OUTPUT_PATH}/${ZLIB}/include"
EOF
}
    # 编译安装 libpng
    cd ${BASE}/source/libpng*
    _make_sh > $tmp_config
    source ./$tmp_config

    make clean
    make $MKTHD && make install
    rm $tmp_config
}

function make_libpng ()
{
    export LIBPNG_FILE_NAME=${LIBPNG}.tar.gz
    export LIBPNG_ARCH_PATH=$ROOT_DIR/libpng/compressed/${LIBPNG_FILE_NAME}
    download_png  || return 1
    tar_package || return 1
    mk_zlib  || return 1
    mk_png  || return 1
}

