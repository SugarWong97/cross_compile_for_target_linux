
HAVEGED=haveged
export CONFIG_HAVEGED_VERSION=1.9.2
export HAVEGED_OUTPUT_PATH=${OUTPUT_PATH}/${HAVEGED}

export HAVEGED_FILE_NAME=${HAVEGED}-${CONFIG_HAVEGED_VERSION}.tar.bz2
export HAVEGED_ARCH_PATH=$ROOT_DIR/${HAVEGED}/compressed/${HAVEGED_FILE_NAME}

get_haveged()
{
    export HAVEGED_FILE_NAME=${HAVEGED}-${CONFIG_HAVEGED_VERSION}.tar.bz2
    export HAVEGED_ARCH_PATH=$ROOT_DIR/${HAVEGED}/compressed/${HAVEGED_FILE_NAME}
    if [ -f "$HAVEGED_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $HAVEGED_ARCH_PATH $ARCHIVE_PATH/$HAVEGED_FILE_NAME
    else
        # https://www.issihosts.com/haveged/downloads.html
        tget https://www.issihosts.com/haveged/haveged-${CONFIG_HAVEGED_VERSION}.tar.gz
    fi
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
    export HAVEGED_FILE_NAME=${HAVEGED}-${CONFIG_HAVEGED_VERSION}.tar.bz2
    get_haveged
    tar_package
    mk_haveged
}
