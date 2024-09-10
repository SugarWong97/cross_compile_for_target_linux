
CONFIG_DOSFSTOOLS_VERSION=4.2.orig
export DOSFSTOOLS_OUTPUT_PATH=${OUTPUT_PATH}/dosfstools

DOSFSTOOLS_VERSION=dosfstools-${CONFIG_DOSFSTOOLS_VERSION}

download_dosfstools () {
    tget http://ftp.de.debian.org/debian/pool/main/d/dosfstools/dosfstools_${CONFIG_DOSFSTOOLS_VERSION}.tar.gz
}

function mk_dosfstools () {
function _make_sh () {
cat<<EOF
    ./configure --host=${BUILD_HOST} \
        --prefix=${DOSFSTOOLS_OUTPUT_PATH}
EOF
}
    # 编译安装 dosfstools
    dir_name=`echo $CONFIG_DOSFSTOOLS_VERSION |  cut -f 1-2 -d "."`
    cd ${CODE_PATH}/dosfstools-${dir_name}*
    _make_sh > $tmp_config
    source ./$tmp_config

    make clean
    make $MKTHD && make install
}

function make_dosfstools ()
{
    download_dosfstools  || return 1
    tar_package || return 1
    mk_dosfstools  || return 1
}

