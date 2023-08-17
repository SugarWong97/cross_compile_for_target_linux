
CANUTILS=canutils-4.0.6
LIBSOCKETCAN=libsocketcan-0.0.12

LIBSOCKETCAN_INSTALL_PATH=${OUTPUT_PATH}/libsocketcan
CANUTILS_INSTALL_PATH=${OUTPUT_PATH}/canutils

download_canutils () {
    #下载包
    #https://git.pengutronix.de/cgit/tools/canutils
    tget https://public.pengutronix.de/software/socket-can/canutils/v4.0/${CANUTILS}.tar.bz2
    #https://git.pengutronix.de/cgit/tools/libsocketcan
    #tget https://git.pengutronix.de/cgit/tools/libsocketcan/snapshot/${LIBSOCKETCAN}.tar.xz
    echo "Using trim code"
}

make_libsocketcan() {
    #mkdir -p ${LIBSOCKETCAN_INSTALL_PATH}

    cd ${CODE_PATH}/${LIBSOCKETCAN}.trim

    make -f Makefile clean
    make -f Makefile CROSS_COMPILE=${BUILD_HOST_} INSTALL_PATH=$LIBSOCKETCAN_INSTALL_PATH/
    #./autogen.sh
    #sed -r -i "/LT_INIT\(win32-dll\)/ s/.*//" configure
    #./configure CC=${_CC} AR=${_AR} \
    #    --prefix=$LIBSOCKETCAN_INSTALL_PATH/ \
    #    --host=$BUILD_HOST

    #make CC=${_CC} AR=${_AR}
    #make install  CC=${_CC} AR=${_AR}
}

make_cantils () {
    cd ${CODE_PATH}/${CANUTILS}

    ./configure --build=i686-linux --target=$BUILD_HOST \
        --prefix=${CANUTILS_INSTALL_PATH}/ --enable-debug \
        libsocketcan_LIBS="-L${LIBSOCKETCAN_INSTALL_PATH}/lib -lsocketcan" \
        libsocketcan_CFLAGS="-I${LIBSOCKETCAN_INSTALL_PATH}/include"
    make INCLUDES="-I${LIBSOCKETCAN_INSTALL_PATH}/include" \
        CFLAGS='-Wall  -g -O1' \
         CC=${_CC} LD=${_LD}
    make install
}


function make_canutils ()
{
    download_canutils  || return 1
    tar_package       || return 1
    make_libsocketcan || return 1
    make_cantils      || return 1
}
