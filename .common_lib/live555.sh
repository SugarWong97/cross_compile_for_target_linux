#!/bin/sh

export LIVE555=live555-latest

function get_live555 () {
    tget http://www.live555.com/liveMedia/public/${LIVE555}.tar.gz
}

function mk_live555 () {
    CONFIG_FILE=config.armlinux
    cd ${CODE_PATH}/live* || return 1

    NEW_LIBS_CONSOLE="-L${OUTPUT_PATH}/${OPENSSL}/lib -lssl -lcrypto"

    #export INCLUDES='$(INCLUDES)'
read -r -d '' NEW_COPTS <<- EOF
\$(INCLUDES)   \
-I. \
-I${OUTPUT_PATH}/${OPENSSL}/include \
-L${OUTPUT_PATH}/${OPENSSL}/lib \
-O2 -DSOCKLEN_T=socklen_t -DNO_SSTREAM=1 -D_LARGEFILE_SOURCE=1 -D_FILE_OFFSET_BITS=64 \
-DNO_STD_LIB -lssl -lcrypto
EOF

    ./genMakefiles  armlinux || return 1

    #make clean
    export COMPILE_OPTS="${NEW_COPTS}"
    export LIBS_FOR_CONSOLE_APPLICATION="${NEW_LIBS_CONSOLE}"
    make CROSS_COMPILE=${BUILD_HOST_} \
        COMPILE_OPTS="${NEW_COPTS}" \
        LIBS_FOR_CONSOLE_APPLICATION="${NEW_LIBS_CONSOLE}" \
        $MKTHD && make install PREFIX=${OUTPUT_PATH}/live555
}

function make_live555 () {
    get_live555
    get_ssl

    tar_package       || return 1
    make_ssl
    mk_live555
}
