CURL=curl
export CONFIG_CURL_VERSION=7.69.1
export CURL_VERSION=curl-${CONFIG_CURL_VERSION}
export CURL_OUTPUT_PATH=${OUTPUT_PATH}/${CURL}

download_curl () {
    tget https://curl.haxx.se/download/${CURL_VERSION}.tar.gz
}

function _gen_curl_sh () {
cat<<EOF
    ./configure \
    --prefix=${CURL_OUTPUT_PATH} \
    --host=${BUILD_HOST} \
    CC=${_CC} \
    CXX=${_CPP}
EOF
}

function mk_curl () {
    cd ${CODE_PATH}/${CURL_VERSION}

    _gen_curl_sh > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make $MKTHD && make install
}

function make_curl ()
{
    export CURL_VERSION=curl-${CONFIG_CURL_VERSION}
    download_curl  || return 1
    tar_package || return 1
    mk_curl  || return 1
}
