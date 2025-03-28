LIBICONV=libiconv-1.15

## for others
export LIBICONV_FILE_NAME=${LIBICONV}.tar.gz
export LIBICONV_ARCH_PATH=$ROOT_DIR/libiconv/compressed/${LIBICONV_FILE_NAME}

get_libiconv () {
    export LIBICONV_FILE_NAME=${LIBICONV}.tar.gz
    export LIBICONV_ARCH_PATH=$ROOT_DIR/libiconv/compressed/${LIBICONV_FILE_NAME}
    if [ -f "$LIBICONV_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        #cp -v $ROOT_DIR/zlib/compressed/${LIBICONV}.tar.gz $ARCHIVE_PATH
        #ln -s $ROOT_DIR/zlib/compressed/${LIBICONV}.tar.gz $ARCHIVE_PATH
        mk_softlink_to_dest $LIBICONV_ARCH_PATH $ARCHIVE_PATH/$LIBICONV_FILE_NAME
    else
        tget http://ftp.gnu.org/pub/gnu/libiconv/${LIBICONV}.tar.gz
        cp $ARCHIVE_PATH/$LIBICONV_FILE_NAME $LIBICONV_ARCH_PATH
    fi
}


mk_iconv () {
    cd ${BASE}/source/${LIBICONV}

    ./configure --host=${BUILD_HOST} --prefix=${OUTPUT_PATH}/${LIBICONV} || return 1
    make $MKTHD && make install
}

make_iconv () {
    export LIBICONV_FILE_NAME=${LIBICONV}.tar.gz
    export LIBICONV_ARCH_PATH=$ROOT_DIR/libiconv/compressed/${LIBICONV_FILE_NAME}
    get_libiconv
    tar_package
    mk_iconv
}
