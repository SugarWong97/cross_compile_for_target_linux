export PCIUTILS=pciutils-3.12.0

## for others
export PCIUTILS_FILE_NAME=${PCIUTILS}.tar.gz
export PCIUTILS_ARCH_PATH=$ROOT_DIR/pciutils/compressed/${PCIUTILS_FILE_NAME}

function _sync_export_var_pciutils()
{
    export PCIUTILS_FILE_NAME=${PCIUTILS}.tar.gz
    export PCIUTILS_ARCH_PATH=$ROOT_DIR/pciutils/compressed/${PCIUTILS_FILE_NAME}
}

function get_pciutils () {
    _sync_export_var_pciutils
    tget_package_from_arch  $PCIUTILS_ARCH_PATH $ARCHIVE_PATH/$PCIUTILS_FILE_NAME  https://mirrors.edge.kernel.org/pub/software/utils/pciutils/${PCIUTILS}.tar.gz
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
    _sync_export_var_pciutils
    get_pciutils
    tar_package       || return 1
    mk_pciutils
}

