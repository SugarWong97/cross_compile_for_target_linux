
DOSFSTOOLS_VERSION=4.2.orig

DOSFSTOOLS=dosfstools-${DOSFSTOOLS_VERSION}

## for others
DOSFSTOOLS_FILE_NAME=${DOSFSTOOLS}.tar.gz
DOSFSTOOLS_ARCH_PATH=$ROOT_DIR/dosfstools/compressed/${DOSFSTOOLS_FILE_NAME}

download_dosfstools () {
    tget http://ftp.de.debian.org/debian/pool/main/d/dosfstools/dosfstools_${DOSFSTOOLS_VERSION}.tar.gz
}

function mk_dosfstools () {
function _make_sh () {
cat<<EOF
    ./configure --host=${BUILD_HOST} \
        --prefix=${OUTPUT_PATH}/dosfstools
EOF
}
    # 编译安装 dosfstools
    cd ${BASE}/source/dosfstools*
    _make_sh > $tmp_config
    source ./$tmp_config

    make clean
    make $MKTHD && make install
    rm $tmp_config
}

function make_dosfstools ()
{
    download_dosfstools  || return 1
    tar_package || return 1
    mk_dosfstools  || return 1
}

