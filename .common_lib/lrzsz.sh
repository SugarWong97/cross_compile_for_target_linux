
LRZSZ_VERSION=0.12.20
LRZSZ_INSTALL=${OUTPUT_PATH}/lrzsz
LRZSZ_INSTALL_HOST=${OUTPUT_PATH_HOST}/lrzsz

#LIBNSL=2.0.0
#LIBNSL_INSTALL=${OUTPUT_PATH}/libnsl

download_lrzsz () {
    cd ${BASE}/compressed
    tget https://ohse.de/uwe/releases/lrzsz-${LRZSZ_VERSION}.tar.gz
    #tget https://github.com/thkukuk/libnsl/releases/download/v${LIBNSL}/libnsl-${LIBNSL}.tar.xz
}

#mk_nsl () {
#    cd $CODE_PATH/libnsl-${LIBNSL}
#
#    ./configure --host=${BUILD_HOST} --prefix=${LIBNSL_INSTALL} \
#        --disable-nsl \
#        --enable-static --disable-shared
#
#    make CC=${_CC} prefix=${LIBNSL_INSTALL} || return -1
#
#    make install
#
#}

mk_lrzsz () {

    cd $CODE_PATH/lrzsz-${LRZSZ_VERSION}

    ./configure --host=${BUILD_HOST} --prefix=${LRZSZ_INSTALL} --disable-nls LIBS=""

    make CC=${_CC} prefix=${LRZSZ_INSTALL}  LIBS="" || return -1

    make install
}

mk_lrzsz_host () {

    cd $CODE_PATH/lrzsz-${LRZSZ_VERSION}

    ./configure --prefix=${LRZSZ_INSTALL_HOST} --disable-nls LIBS=""

    make prefix=${LRZSZ_INSTALL_HOST}  LIBS="" || return -1

    make install
}

function _common_make_lrzsz ()
{
    download_lrzsz  || return 1
    tar_package || return 1
}


function make_lrzsz ()
{
    _common_make_lrzsz || return 1
    mk_lrzsz  || return 1
    mk_lrzsz
}

function make_lrzsz_host ()
{
    _common_make_lrzsz || return 1
    mk_lrzsz_host
}
