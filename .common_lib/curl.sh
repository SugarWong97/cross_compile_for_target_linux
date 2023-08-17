CURL=curl
CURL_VERSION=7.69.1

download_curl () {
    tget https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz
}

function _gen_curl_sh () {
cat<<EOF
    ./configure \
    --prefix=${OUTPUT_PATH}/${CURL} \
    --host=${BUILD_HOST} \
    CC=${_CC} \
    CXX=${_CPP}
EOF
}

function mk_curl () {
    cd ${CODE_PATH}/curl*

    _gen_curl_sh > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make $MKTHD && make install
}

function make_curl ()
{
    download_curl  || return 1
    tar_package || return 1
    mk_curl  || return 1
}
