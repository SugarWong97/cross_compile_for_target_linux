export CONFIG_V4L_UTILS_VERSION=1.22.1
export V4L_UTILS=v4l-utils
export V4L_UTILS_VERSION=v4l-utils-${CONFIG_V4L_UTILS_VERSION}
export V4L_UTILS_OUTPUT_PATH=${OUTPUT_PATH}/${V4L_UTILS}

download_v4l_utils () {
    tget https://linuxtv.org/downloads/v4l-utils/v4l-utils-${CONFIG_V4L_UTILS_VERSION}.tar.bz2
}

function mk_v4l_utils () {
    echo prefix=${V4L_UTILS_OUTPUT_PATH}

(
cat <<EOF
    cd ${CODE_PATH}/${V4L_UTILS_VERSION}

     ./configure \
    --host=${BUILD_HOST} \
    --prefix=${V4L_UTILS_OUTPUT_PATH} \
    --with-udevdir=${V4L_UTILS_OUTPUT_PATH} \
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
) > ${CODE_PATH}/${V4L_UTILS_VERSION}/contrib/test/Makefile

    make -C ${CODE_PATH}/${V4L_UTILS_VERSION} $MKTHD
    make -C ${CODE_PATH}/${V4L_UTILS_VERSION} install
}

function make_v4l_utils ()
{
    export V4L_UTILS=v4l-utils-${V4L_UTILS_VERSION}
    download_v4l_utils || return 1
    tar_package || return 1
    mk_v4l_utils || return 1
}
