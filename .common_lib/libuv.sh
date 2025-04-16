LIBUV=libuv
export CONFIG_LIBUV_VERSION=1.50.0
export LIBUV_VERSION=${LIBUV}-v${CONFIG_LIBUV_VERSION}

export LIBUV_OUTPUT_PATH=${OUTPUT_PATH}/${LIBUV}

## for others
export LIBUV_FILE_NAME=${LIBUV_VERSION}.tar.gz
export LIBUV_ARCH_PATH=$ROOT_DIR/libuv/compressed/${LIBUV_FILE_NAME}

function _sync_export_var_libuv()
{
    export LIBUV_VERSION=${LIBUV}-${CONFIG_LIBUV_VERSION}
    export LIBUV_FILE_NAME=${LIBUV_VERSION}.tar.gz
    export LIBUV_ARCH_PATH=$ROOT_DIR/libuv/compressed/${LIBUV_FILE_NAME}
}

### LIBUV
function get_libuv () {
    _sync_export_var_libuv

    tget_package_from_arch_with_rename $LIBUV_ARCH_PATH  $ARCHIVE_PATH/$LIBUV_FILE_NAME https://github.com/libuv/libuv/archive/refs/tags/v${CONFIG_LIBUV_VERSION}.tar.gz $LIBUV_FILE_NAME
}

function mk_libuv () {
    _sync_export_var_libuv
bash <<EOF
    cd ${CODE_PATH}/${LIBUV_VERSION}

    sh autogen.sh
    ./configure --prefix=${LIBUV_OUTPUT_PATH} --host=${BUILD_HOST} CC=${_CC}
    make clean
    # make check//该步骤可以省略，只是校验一下，直接安装，由于运行平台不同check会报错
    make $MKTHD && make install
EOF
}

function make_libuv () {
    _sync_export_var_libuv
    get_libuv
    tar_package       || return 1
    mk_libuv
}

