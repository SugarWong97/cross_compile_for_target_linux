##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    2023年2月9日 11:22:22
##
#!/bin/bash

source ../.common
VERSION=1.22.1
export V4L_UTILS=v4l-utils-${VERSION}
V4L_UTILS_DIR=${OUTPUT_PATH}/${V4L_UTILS}

download_v4l_utils () {
    tget https://linuxtv.org/downloads/v4l-utils/v4l-utils-${VERSION}.tar.bz2
}

function make_v4l_utils () {
    echo prefix=${V4L_UTILS_DIR}

(
cat <<EOF
    cd ${CODE_PATH}/${V4L_UTILS}

     ./configure \
    --host=${BUILD_HOST} \
    --prefix=${V4L_UTILS_DIR} \
    --with-udevdir=${V4L_UTILS_DIR} \
    --enable-static
EOF
) > .build.sh
    bash .build.sh
    cust_tab=`echo -e '\t'`
(
cat <<EOF
.PHONY: all install
all:
${cust_tab}@echo 'skip'
install:
${cust_tab}@echo 'skip'
EOF
) > ${CODE_PATH}/${V4L_UTILS}/contrib/test/Makefile

    make -C ${CODE_PATH}/${V4L_UTILS} $MKTHD
    make -C ${CODE_PATH}/${V4L_UTILS} install
}

function build_v4l_utils ()
{
    download_v4l_utils || return 1
    tar_package || return 1
    make_v4l_utils || return 1
}
build_v4l_utils || echo "Err"

exit $?
