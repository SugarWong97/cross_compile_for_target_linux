LIBMODBUS_VERSION=3.1.4

export LIBMODBUS=libmodbus
LIBMODBUS_OUTPUT=${OUTPUT_PATH}/${LIBMODBUS}

function download_libmodbus () {
    # https://github.com/stephane/libmodbus/releases/tag/v3.1.10
    tget   http://libmodbus.org/releases/libmodbus-${LIBMODBUS_VERSION}.tar.gz
}

function mk_libmodbus () {
    libmodbus_dir=${CODE_PATH}/libmodbus-${1}*
    cd $libmodbus_dir;
    ./configure --prefix=${LIBMODBUS_OUTPUT} --host=arm-linux --enable-static ac_cv_func_malloc_0_nonnull=yes CC=${BUILD_HOST_}gcc
    make clean;
    make CROSS_COMPILE=${BUILD_HOST_} prefix=${LIBMODBUS_OUTPUT}
    make install
}

function make_libmodbus ()
{
    download_libmodbus  || return 1
    tar_package || return 1

    mk_libmodbus $LIBMODBUS_VERSION
}
