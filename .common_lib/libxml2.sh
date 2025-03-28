
LIBXML2=libxml2-2.9.9
## for others
export LIBXML2_FILE_NAME=${LIBXML2}.tar.gz
export LIBXML2_ARCH_PATH=$ROOT_DIR/libxml2/compressed/${LIBXML2_FILE_NAME}

get_libxml2 () {
    export LIBXML2_FILE_NAME=${LIBXML2}.tar.gz
    export LIBXML2_ARCH_PATH=$ROOT_DIR/libxml2/compressed/${LIBXML2_FILE_NAME}
    if [ -f "$LIBXML2_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        #cp -v $ROOT_DIR/zlib/compressed/${LIBXML2}.tar.gz $ARCHIVE_PATH
        #ln -s $ROOT_DIR/zlib/compressed/${LIBXML2}.tar.gz $ARCHIVE_PATH
        mk_softlink_to_dest $LIBXML2_ARCH_PATH $ARCHIVE_PATH/$LIBXML2_FILE_NAME
        return
    else
        tget http://distfiles.macports.org/libxml2/${LIBXML2}.tar.gz
    fi
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
    export LIBXML2_FILE_NAME=${LIBXML2}.tar.gz
    export LIBXML2_ARCH_PATH=$ROOT_DIR/libxml2/compressed/${LIBXML2_FILE_NAME}
    get_libxml2
    tar_package
    mk_libxml2
}
