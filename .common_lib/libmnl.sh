
LIBMNL=1.0.5
LIBMNL_INSTALL=${OUTPUT_PATH}/libmnl

download_libmnl ()
{
    tget https://www.netfilter.org/pub/libmnl/libmnl-${LIBMNL}.tar.bz2
}

get_libmnl ()
{
    echo "TODO: get_libmnl"
    exit 0
}

mk_libmnl () {
    cd $CODE_PATH/libmnl-${LIBMNL}

    ./configure --host=${BUILD_HOST} --prefix=${LIBMNL_INSTALL} \
        --enable-static --disable-shared

    make CC=${_CC} prefix=${LIBMNL_INSTALL} || return -1

    make install prefix=${LIBMNL_INSTALL}

}
