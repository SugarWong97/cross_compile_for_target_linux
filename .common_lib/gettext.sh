
export CONFIG_GETTEXT_VERSION=0.21
export GETTEXT=gettext
export GETTEXT_VERSION=${GETTEXT}-${CONFIG_GETTEXT_VERSION}

download_package_for_gettext () {
    tget https://ftp.gnu.org/pub/gnu/gettext/gettext-${CONFIG_GETTEXT_VERSION}.tar.gz
}

function gen_gettext_make_sh () {
cat<<EOF
    ./configure --prefix=${OUTPUT_PATH}/${GETTEXT} \
        --host=${BUILD_HOST} \
        CC=${_CC} CXX=${_CXX} \
        CFLAGS="-fPIC"
EOF
}

function mk_gettext() {

    cd ${CODE_PATH}/${GETTEXT_VERSION}
    gen_gettext_make_sh > $tmp_config
    bash ./$tmp_config || return 1
    make clean
    make $MKTHD && make install
}

function make_gettext ()
{
    download_package_for_gettext  || return 1
    tar_package || return 1
    mk_gettext
}
