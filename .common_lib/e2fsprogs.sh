
CONFIG_E2FSPROGS_VERSION=1.45.6
E2FSPROGS_VERSION=e2fsprogs-$CONFIG_E2FSPROGS_VERSION
export E2FSPROGS_OUTPUT_PATH=${OUTPUT_PATH}/e2fsprogs

download_e2fsprogs () {
    tget https://udomain.dl.sourceforge.net/project/e2fsprogs/e2fsprogs/v${CONFIG_E2FSPROGS_VERSION}/e2fsprogs-${CONFIG_E2FSPROGS_VERSION}.tar.gz
}

function mk_e2fsprogs () {
function _make_sh () {
cat<<EOF
    CC=${BUILD_HOST_}gcc ../configure --host=arm-linux --enable-elf-shlibs \
        --prefix=${E2FSPROGS_OUTPUT_PATH}/ \
        --datadir=${E2FSPROGS_OUTPUT_PATH}/doc \
        --with-udev-rules-dir=${E2FSPROGS_OUTPUT_PATH} \
        --with-crond-dir=${E2FSPROGS_OUTPUT_PATH} \
        --with-systemd-unit-dir=${E2FSPROGS_OUTPUT_PATH}
EOF
}

    cd ${CODE_PATH}/${E2FSPROGS_VERSION}

    mkdir configure_dir -p
    cd configure_dir

    _make_sh > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make  $MKTHD && make install
}

function make_e2fsprogs ()
{
    download_e2fsprogs  || return 1
    tar_package  || return 1
    mk_e2fsprogs  || return 1
}
