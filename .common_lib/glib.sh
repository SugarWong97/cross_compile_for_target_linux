export GLIB=glib
#export CONFIG_GLIB_VERSION=2.80.5
export CONFIG_GLIB_VERSION=2.56.4
export GLIB_VERSION=${GLIB}-${CONFIG_GLIB_VERSION}


## for others
GLIB_FILE_NAME=${GLIB}.tar.gz
GLIB_ARCH_PATH=$ROOT_DIR/glib/compressed/${GLIB_FILE_NAME}

### GLIB
function get_glib () {
    get_libffi
    get_zlib
    if [ -f "$GLIB_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $GLIB_ARCH_PATH $ARCHIVE_PATH/$GLIB_FILE_NAME
        return
    else
        # 2.56.1 -> 2.56
        local subversion=`echo ${CONFIG_GLIB_VERSION%.*}`

        ### X! https://gitlab.gnome.org/GNOME/glib/-/archive/2.80.5/glib-2.80.5.tar.gz
        tget https://download.gnome.org/sources/glib/${subversion}/${GLIB_VERSION}.tar.xz
    fi
}

function mk_glib () {
    mk_zlib
    mk_libffi
bash <<EOF
    cd ${CODE_PATH}/${GLIB_VERSION}

    LIBFFI_CFLAGS='-I${OUTPUT_PATH}/${LIBFFI}/include' \
    LIBFFI_LIBS='-lffi -L=${OUTPUT_PATH}/${LIBFFI}/lib -L=${OUTPUT_PATH}/${LIBFFI}/lib64' \
    ZLIB_CFLAGS='-I${OUTPUT_PATH}/${ZLIB}/include' \
    ZLIB_LIBS='-lz -L${OUTPUT_PATH}/${ZLIB}/lib' \
    ./configure --host=${BUILD_HOST} --prefix=${OUTPUT_PATH}/${GLIB} \
    PKG_CONFIG_PATH=${OUTPUT_PATH}/${LIBFFI}/lib/pkgconfig:${OUTPUT_PATH}/${ZLIB}/lib/pkgconfig \
    glib_cv_stack_grows=no glib_cv_uscore=yes \
    ac_cv_func_posix_getpwuid_r=yes ac_cv_func_posix_getgrgid_r=yes \
    --with-pcre=internal --enable-libmount=no

    make clean
    make $MKTHD && make install
EOF
}

function make_glib () {
    get_glib
    tar_package       || return 1
    mk_glib
}
