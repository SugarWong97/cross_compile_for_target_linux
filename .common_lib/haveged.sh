
HAVEGED=haveged
export CONFIG_HAVEGED_VERSION=1.9.2
export HAVEGED_OUTPUT_PATH=${OUTPUT_PATH}/${HAVEGED}

export HAVEGED_FILE_NAME=${HAVEGED}-${CONFIG_HAVEGED_VERSION}.tar.bz2
export HAVEGED_ARCH_PATH=$ROOT_DIR/${HAVEGED}/compressed/${HAVEGED_FILE_NAME}

function _sync_export_var_haveged()
{
    export HAVEGED_FILE_NAME=${HAVEGED}-${CONFIG_HAVEGED_VERSION}.tar.bz2
    export HAVEGED_ARCH_PATH=$ROOT_DIR/${HAVEGED}/compressed/${HAVEGED_FILE_NAME}
}

get_haveged()
{
    _sync_export_var_haveged

    # https://www.issihosts.com/haveged/downloads.html
    tget_package_from_arch $HAVEGED_ARCH_PATH  $ARCHIVE_PATH/$HAVEGED_FILE_NAME https://www.issihosts.com/haveged/haveged-${CONFIG_HAVEGED_VERSION}.tar.gz
}

function mk_haveged () {
bash <<EOF
    cd ${CODE_PATH}/${HAVEGED}*
    CC=${_CC} ./configure --prefix=${HAVEGED_OUTPUT_PATH} --host=${BUILD_HOST}
    make clean
    make $MKTHD && make install
EOF

}

function help_haveged () {
cat <<EOF
haveged -F -d 32 -w 1024 --verbose=1 &
EOF

}

make_haveged()
{
    _sync_export_var_haveged
    get_haveged
    tar_package
    mk_haveged
}
