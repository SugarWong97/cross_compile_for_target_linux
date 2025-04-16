LIBICONV=libiconv-1.15

## for others
export LIBICONV_FILE_NAME=${LIBICONV}.tar.gz
export LIBICONV_ARCH_PATH=$ROOT_DIR/libiconv/compressed/${LIBICONV_FILE_NAME}

function _sync_export_var_libiconv()
{
    export LIBICONV_FILE_NAME=${LIBICONV}.tar.gz
    export LIBICONV_ARCH_PATH=$ROOT_DIR/libiconv/compressed/${LIBICONV_FILE_NAME}
}

get_libiconv () {
    _sync_export_var_libiconv

    tget_package_from_arch $LIBICONV_ARCH_PATH  $ARCHIVE_PATH/$LIBICONV_FILE_NAME http://ftp.gnu.org/pub/gnu/libiconv/${LIBICONV}.tar.gz
}


mk_iconv () {
    cd ${BASE}/source/${LIBICONV}

    ./configure --host=${BUILD_HOST} --prefix=${OUTPUT_PATH}/${LIBICONV} || return 1
    make $MKTHD && make install
}

make_iconv () {
    _sync_export_var_libiconv
    get_libiconv
    tar_package
    mk_iconv
}
