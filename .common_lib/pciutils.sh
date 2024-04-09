export PCIUTILS=pciutils-3.12.0

## for others
PCIUTILS_FILE_NAME=${PCIUTILS}.tar.gz
PCIUTILS_ARCH_PATH=$ROOT_DIR/pciutils/compressed/${PCIUTILS_FILE_NAME}

### PCIUTILS
function get_pciutils () {
    if [ -f "$PCIUTILS_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $PCIUTILS_ARCH_PATH $ARCHIVE_PATH/$PCIUTILS_FILE_NAME
        return
    else
        tget https://mirrors.edge.kernel.org/pub/software/utils/pciutils/${PCIUTILS}.tar.gz
    fi
}

function mk_pciutils () {
    (
cat <<EOF
    cd ${CODE_PATH}/${PCIUTILS}
    make clean
    make CROSS_COMPILE=${BUILD_HOST_} HOST=arm64-linux ZLIB=no DNS=no $MKTHD
    make CROSS_COMPILE=${BUILD_HOST_} HOST=arm64-linux ZLIB=no DNS=no PREFIX=${OUTPUT_PATH}/${PCIUTILS} install
EOF
) > ./.build.sh
    source ./.build.sh

    (
cat <<EOF
mkdir -p /usr/local/share/ || exit
cp -v share/pci.ids  /usr/local/share/
EOF
) > ${OUTPUT_PATH}/${PCIUTILS}/install.pci.ids
    chmod +x ${OUTPUT_PATH}/${PCIUTILS}/install.pci.ids
}

function make_pciutils () {
    get_pciutils
    tar_package       || return 1
    mk_pciutils
}

