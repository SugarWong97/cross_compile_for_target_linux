export LIBFFI=libffi
export CONFIG_LIBFFI_VERSION=3.4.5
LIBFFI_FILE_NAME=${LIBFFI}-${CONFIG_LIBFFI_VERSION}.tar.bz2
LIBFFI_ARCH_PATH=$ROOT_DIR/${LIBFFI}/compressed/${LIBFFI_FILE_NAME}
LIBFFI_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/libffi.sh

get_libffi()
{
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
    CC=${_CC} ./configure --prefix=${OUTPUT_PATH}/${LIBFFI} --host=${BUILD_HOST}
    make clean
    make $MKTHD && make install
EOF
}

make_libffi()
{
    get_libffi
    tar_package
    mk_libffi
}
