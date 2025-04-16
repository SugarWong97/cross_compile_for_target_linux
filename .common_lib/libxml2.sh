
LIBXML2=libxml2-2.9.9
## for others
export LIBXML2_FILE_NAME=${LIBXML2}.tar.gz
export LIBXML2_ARCH_PATH=$ROOT_DIR/libxml2/compressed/${LIBXML2_FILE_NAME}

function _sync_export_var_libxml2()
{
    export LIBXML2_FILE_NAME=${LIBXML2}.tar.gz
    export LIBXML2_ARCH_PATH=$ROOT_DIR/libxml2/compressed/${LIBXML2_FILE_NAME}
}

get_libxml2 () {
    _sync_export_var_libxml2
    tget_package_from_arch $LIBXML2_ARCH_PATH  $ARCHIVE_PATH/$LIBXML2_FILE_NAME http://distfiles.macports.org/libxml2/${LIBXML2}.tar.gz
}


mk_libxml2 () {
    cd ${BASE}/source/${LIBXML2}

    ./configure \
    --without-zlib \
    --without-lzma \
    --without-python \
    --prefix=${OUTPUT_PATH}/${LIBXML2} \
    --host=${BUILD_HOST} || return 1
    make $MKTHD && make install
}
make_libxml2()
{
    _sync_export_var_libxml2
    get_libxml2
    tar_package
    mk_libxml2
}
