#!/bin/bash

export ELFUTILS=elfutils
export CONFIG_ELFUTILS_VERSION=0.179
export ELFUTILS_VERSION=${ELFUTILS}-${CONFIG_ELFUTILS_VERSION}
export ELFUTILS_OUTPUT_PATH=${OUTPUT_PATH}/${ELFUTILS}/


get_elfutils () {
    get_zlib
    # https://sourceware.org/elfutils/ftp/
    tget https://sourceware.org/elfutils/ftp/$CONFIG_ELFUTILS_VERSION/${ELFUTILS_VERSION}.tar.bz2
}

function gen_elfutils_make_sh () {
cat <<EOF
    cd ${CODE_PATH}/${ELFUTILS_VERSION}

LDFLAGS="-L${OUTPUT_PATH}/${ZLIB}/lib" \
CFLAGS="-I${OUTPUT_PATH}/${ZLIB}/include" \
LIBS="-lz" \
./configure \
    --with-zlib=${OUTPUT_PATH}/${ZLIB} \
     --disable-debuginfod \
--prefix=${ELFUTILS_OUTPUT_PATH}/ \
--host=${BUILD_HOST}

    make clean
    make $MKTHD && make install
EOF
}

function mk_elfutils() {

    cd ${CODE_PATH}/${ELFUTILS_VERSION}
    gen_elfutils_make_sh > $tmp_config
    bash ./$tmp_config || return 1
    make clean
    make $MKTHD && make install
}

function make_elfutils ()
{
    get_elfutils  || return 1
    tar_package || return 1
    make_zlib || return 1
    mk_elfutils
}

