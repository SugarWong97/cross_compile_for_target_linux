export LIVE555=live555

#export CONFIG_LIVE555_VERSION=2025.01.17
export CONFIG_LIVE555_VERSION=latest

export LIVE555_VERSION=${LIVE555}-${CONFIG_LIVE555_VERSION}

export LIVE555_OUTPUT_PATH=${OUTPUT_PATH}/${LIVE555}

function get_live555 () {
    if [ "$CONFIG_LIVE555_VERSION" = "latest" ]; then
        tget http://www.live555.com/liveMedia/public/${LIVE555_VERSION}.tar.gz
    else
        tget https://download.videolan.org/pub/contrib/live555/live.${CONFIG_LIVE555_VERSION}.tar.gz
    fi
}

function mk_live555 () {
    cd ${CODE_PATH}/live || return 1

read -r -d '' NEW_COPTS <<- EOF
\$(INCLUDES)   \
-I. \
-IliveMedia/include/ \
-I${OPENSSL_OUTPUT_PATH}/include \
-L${OPENSSL_OUTPUT_PATH}/lib \
-O2 -DSOCKLEN_T=socklen_t -DNO_SSTREAM=1 -D_LARGEFILE_SOURCE=1 -D_FILE_OFFSET_BITS=64 \
-DNO_STD_LIB -lssl -lcrypto
EOF

    ./genMakefiles  armlinux || return 1

    export NEW_LIBS_CONSOLE="-I${OPENSSL_OUTPUT_PATH}/include -L${OPENSSL_OUTPUT_PATH}/lib -lssl -lcrypto"
    #bash << EOF #BUG
    export COMPILE_OPTS="${NEW_COPTS}"
    export LIBS_FOR_CONSOLE_APPLICATION="${NEW_LIBS_CONSOLE}"
    make clean
    make CROSS_COMPILE=${BUILD_HOST_} \
        COMPILE_OPTS="${NEW_COPTS}" \
        LIBS_FOR_CONSOLE_APPLICATION="${NEW_LIBS_CONSOLE}" \
        $MKTHD && make install PREFIX=${LIVE555_OUTPUT_PATH}
    #EOF
}

function make_live555 () {
    rm ${CODE_PATH}/live -rf
    get_live555
    get_ssl

    tar_package       || return 1
    make_ssl
    mk_live555
}

