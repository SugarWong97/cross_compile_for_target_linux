
IFENSLAVE_VERSION=2.9
IFENSLAVE_INSTALL=${OUTPUT_PATH}/ifenslave
IFENSLAVE_INSTALL_HOST=${OUTPUT_PATH_HOST}/ifenslave

download_ifenslave () {
    cd ${BASE}/compressed
    tget http://snapshot.debian.org/archive/debian/20170102T091407Z/pool/main/i/ifenslave/ifenslave_${IFENSLAVE_VERSION}.tar.xz
}

mk_ifenslave () {

    cd $CODE_PATH/ifenslave-${IFENSLAVE_VERSION}

    ./configure --host=${BUILD_HOST} --prefix=${IFENSLAVE_INSTALL} LIBS=""

    make CC=${_CC} prefix=${IFENSLAVE_INSTALL}  LIBS="" || return -1

    make install
}

_mk_ifenslave () {
    local dest_dir="$1"

    mkdir -p $dest_dir/bin/
    cp `find $CODE_PATH -type f  -name "ifenslave"` $dest_dir/bin -v
}

function _common_make_ifenslave ()
{
    download_ifenslave  || return 1
    tar_package || return 1
}

function make_ifenslave ()
{
    _common_make_ifenslave || return 1
    _mk_ifenslave $IFENSLAVE_INSTALL
}

function make_ifenslave_host ()
{
    _common_make_ifenslave || return 1
    _mk_ifenslave $IFENSLAVE_INSTALL_HOST
}
