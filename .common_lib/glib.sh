export GLIB=glib
#export CONFIG_GLIB_VERSION=2.80.5
export CONFIG_GLIB_VERSION=2.56.4
export GLIB_VERSION=${GLIB}-${CONFIG_GLIB_VERSION}
export GLIB_OUTPUT_PATH=${OUTPUT_PATH}/${GLIB}

## for others
GLIB_FILE_NAME=${GLIB}.tar.gz
GLIB_ARCH_PATH=$ROOT_DIR/glib/compressed/${GLIB_FILE_NAME}

function _sync_export_var_glib()
{
    export GLIB_VERSION=${GLIB}-${CONFIG_GLIB_VERSION}
    export GLIB_FILE_NAME=${GLIB}.tar.gz
    export GLIB_ARCH_PATH=$ROOT_DIR/glib/compressed/${GLIB_FILE_NAME}
}

### GLIB
function get_glib () {
    _sync_export_var_glib
    get_libffi
    get_zlib

    # 2.56.1 -> 2.56
    local subversion=`echo ${CONFIG_GLIB_VERSION%.*}`
    tget_package_from_arch $GLIB_ARCH_PATH  $ARCHIVE_PATH/$GLIB_FILE_NAME  https://download.gnome.org/sources/glib/${subversion}/${GLIB_VERSION}.tar.xz
}

function mk_glib () {
    _sync_export_var_glib
    mk_zlib
    mk_libffi
bash <<EOF
    cd ${CODE_PATH}/${GLIB_VERSION}

    LIBFFI_CFLAGS='-I${LIBFFI_OUTPUT_PATH}/include' \
    LIBFFI_LIBS='-lffi -L=${LIBFFI_OUTPUT_PATH}/lib -L=${LIBFFI_OUTPUT_PATH}/lib64' \
    ZLIB_CFLAGS='-I${ZLIB_OUTPUT_PATH}/include' \
    ZLIB_LIBS='-lz -L${ZLIB_OUTPUT_PATH}/lib' \
    ./configure --host=${BUILD_HOST} --prefix=${GLIB_OUTPUT_PATH} \
    PKG_CONFIG_PATH=${LIBFFI_OUTPUT_PATH}/lib/pkgconfig:${ZLIB_OUTPUT_PATH}/lib/pkgconfig \
    glib_cv_stack_grows=no glib_cv_uscore=yes \
    ac_cv_func_posix_getpwuid_r=yes ac_cv_func_posix_getgrgid_r=yes \
    --with-pcre=internal --enable-libmount=no

    make clean
    make $MKTHD && make install
EOF
}

function make_glib () {
    _sync_export_var_glib
    get_glib
    tar_package       || return 1
    mk_glib
}
