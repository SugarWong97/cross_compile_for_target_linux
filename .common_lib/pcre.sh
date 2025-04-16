PCRE=pcre
export CONFIG_PCRE_VERSION=8.30
export PCRE_VERSION=${PCRE}-${CONFIG_PCRE_VERSION}

export PCRE_OUTPUT_PATH=${OUTPUT_PATH}/${PCRE}

## for others
export PCRE_FILE_NAME=${PCRE_VERSION}.tar.bz2
export PCRE_ARCH_PATH=$ROOT_DIR/pcre/compressed/${PCRE_FILE_NAME}

function _sync_export_var_pcre()
{
    export PCRE_VERSION=${PCRE}-${CONFIG_PCRE_VERSION}
    export PCRE_FILE_NAME=${PCRE_VERSION}.tar.bz2
    export PCRE_ARCH_PATH=$ROOT_DIR/pcre/compressed/${PCRE_FILE_NAME}
}

### PCRE
function get_pcre () {
    _sync_export_var_pcre
    #     https://jaist.dl.sourceforge.net/project/pcre/pcre/8.30/pcre-8.30.tar.bz2
    tget_package_from_arch $PCRE_ARCH_PATH $ARCHIVE_PATH/$PCRE_FILE_NAME  https://jaist.dl.sourceforge.net/project/pcre/pcre/$CONFIG_PCRE_VERSION/${PCRE_VERSION}.tar.bz2
}

function mk_pcre () {
    export PCRE_VERSION=${PCRE}-${CONFIG_PCRE_VERSION}
bash <<EOF
export _CC="${BUILD_HOST_}gcc"
export _CPP="${BUILD_HOST_}g++"
export _CXX="${BUILD_HOST_}g++"
export _LD="${BUILD_HOST_}ld"
export _AR="${BUILD_HOST_}ar"
export _RANLIB="${BUILD_HOST_}ranlib"
export _STRIP="${BUILD_HOST_}strip"
    cd ${CODE_PATH}/${PCRE_VERSION}
    ./configure  --host=i386 --prefix=${PCRE_OUTPUT_PATH} CC=${_CC} CXX=$_CXX LD=_LD AR=$_AR
    #./configure CC=${_CC}  --prefix=${PCRE_OUTPUT_PATH} --host=arm-linux --disable-static #--disable-share
    #CC=aarch64-linux-gnu-gcc --host=aarch64-linux-gnu
    make clean
    make AR=$_AR LD=$_LD CC=${_CC} CXX=$_CXX $MKTHD && make install
EOF
}

function make_pcre () {
    _sync_export_var_pcre
    get_pcre
    tar_package       || return 1
    mk_pcre
}
