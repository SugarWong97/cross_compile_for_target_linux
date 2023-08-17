
export LIBCAP=libcap

export LIBCAP_VERSION=2.67  # 03-Feb-2023 05:20

export LIBCAP_OUTPUT=${OUTPUT_PATH}/${LIBCAP}

function download_libcap () {
    # https://mirrors.edge.kernel.org/pub/linux/libs/security/linux-privs/libcap2/
    tget   https://mirrors.edge.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-${LIBCAP_VERSION}.tar.gz
}

function mk_libcap () {
    libcap_dir=${CODE_PATH}/libcap*${1}*
    cd $libcap_dir;
    make clean -C $libcap_dir
    CROSS_COMPILE=aarch64-none-linux-gnu- BUILD_CC=gcc make prefix=${LIBCAP_OUTPUT} install  -C $libcap_dir
}

function make_libcap ()
{
    download_libcap  || return 1
    tar_package || return 1

    mk_libcap $LIBCAP_VERSION
}
