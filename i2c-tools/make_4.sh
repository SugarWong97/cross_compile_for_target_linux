#
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#
#    File Name:  make.sh
#    Created  :  2020-10-17 09:38:39
#
#
#!/bin/sh

source ../.common

I2C_TOOLS=i2c-tools-4.3

I2_INSTALL_PATH=${OUTPUT_PATH}/i2c-tools

download_package () {
    cd ${BASE}/compressed
    #下载包
    tget https://mirrors.edge.kernel.org/pub/software/utils/i2c-tools/${I2C_TOOLS}.tar.xz
}

make_taget () {
    cd ${BASE}/source/${I2C_TOOLS}
    mkdir -p ${I2_INSTALL_PATH}
    CC=${_CC} LD=${_LD} PREFIX=${I2_INSTALL_PATH} \
        BUILD_DYNAMIC_LIB=0 \
        USE_STATIC_LIB=1 \
        make

    CC=${_CC} LD=${_LD} PREFIX=${I2_INSTALL_PATH} \
        BUILD_DYNAMIC_LIB=0 \
        USE_STATIC_LIB=1 \
        make install
}

function make_build ()
{
    download_package  || return 1
    tar_package  || return 1
    make_taget  || return 1
}

make_build || echo "Err"
