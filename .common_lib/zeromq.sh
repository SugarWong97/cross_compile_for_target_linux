
ZEROMQ=zeromq

export CONFIG_ZEROMQ_LIB_VERSION=4.3.4
export CONFIG_ZEROMQ_CPP_VERSION=4.8.0

export ZEROMQ_LIB_VERSION=zeromq-${CONFIG_ZEROMQ_LIB_VERSION}
export ZEROMQ_CPP_VERSION=cppzmq-${CONFIG_ZEROMQ_CPP_VERSION}
export ZEROMQ_OUTPUT_PATH=${OUTPUT_PATH}/${ZEROMQ}

function download_zeromq () {
    tget            https://github.com/zeromq/libzmq/releases/download/v${CONFIG_ZEROMQ_LIB_VERSION}/${ZEROMQ_LIB_VERSION}.tar.gz
    tget_and_rename https://github.com/zeromq/cppzmq/archive/refs/tags/v${CONFIG_ZEROMQ_CPP_VERSION}.tar.gz  ${ZEROMQ_CPP_VERSION}.tar.gz
}

function mk_zeromq () {
    bash <<EOF

    cd ${CODE_PATH}/${ZEROMQ_LIB_VERSION}

    ./configure   --without-libsodium \
    --prefix=${ZEROMQ_OUTPUT_PATH}/ \
    --host=${BUILD_HOST}

    make clean
    make $MKTHD && make install
EOF
}

function get_zeromq_hpp () {
    bash <<EOF
    cd ${CODE_PATH}/${ZEROMQ_CPP_VERSION}

    cp -v *.hpp ${ZEROMQ_OUTPUT_PATH}/include
EOF
}

function make_zeromq ()
{
    export ZEROMQ_LIB_VERSION=zeromq-${CONFIG_ZEROMQ_LIB_VERSION}
    export ZEROMQ_CPP_VERSION=cppzmq-${CONFIG_ZEROMQ_CPP_VERSION}
    download_zeromq  || return 1
    tar_package || return 1

    mk_zeromq  || return 1
    get_zeromq_hpp
}
