LIBFFI=libffi
export CONFIG_LIBFFI_VERSION=3.4.5
export LIBFFI_OUTPUT_PATH=${OUTPUT_PATH}/${LIBFFI}

export LIBFFI_FILE_NAME=${LIBFFI}-${CONFIG_LIBFFI_VERSION}.tar.bz2
export LIBFFI_ARCH_PATH=$ROOT_DIR/${LIBFFI}/compressed/${LIBFFI_FILE_NAME}

get_libffi()
{
    export LIBFFI_FILE_NAME=${LIBFFI}-${CONFIG_LIBFFI_VERSION}.tar.bz2
    export LIBFFI_ARCH_PATH=$ROOT_DIR/${LIBFFI}/compressed/${LIBFFI_FILE_NAME}
    if [ -f "$LIBFFI_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $LIBFFI_ARCH_PATH $ARCHIVE_PATH/$LIBFFI_FILE_NAME
    else
        # https://github.com/libffi/libffi/releases/download/v3.4.5/libffi-3.4.5.tar.gz
        tget https://github.com/libffi/libffi/releases/download/v${CONFIG_LIBFFI_VERSION}/libffi-${CONFIG_LIBFFI_VERSION}.tar.gz
    fi
}

function mk_libffi () {
bash <<EOF
    cd ${CODE_PATH}/${LIBFFI}*
    CC=${_CC} ./configure --prefix=${LIBFFI_OUTPUT_PATH} --host=${BUILD_HOST}
    make clean
    make $MKTHD && make install
EOF
}

make_libffi()
{
    export LIBFFI_FILE_NAME=${LIBFFI}-${CONFIG_LIBFFI_VERSION}.tar.bz2
    get_libffi
    tar_package
    mk_libffi
}
