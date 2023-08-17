I2C_TOOLS_V3=i2c-tools_3.0.3
I2C_TOOLS_V4=i2c-tools-4.3

I2_V3_INSTALL_PATH=${OUTPUT_PATH}/$I2C_TOOLS_V3
I2_V4_INSTALL_PATH=${OUTPUT_PATH}/$I2C_TOOLS_V4
############### 3 ###############
download_i2c_tools_v3 () {
    tget https://launchpadlibrarian.net/70776071/${I2C_TOOLS_V3}.orig.tar.bz2
}

mk_i2c_tools_v3 () {
    cd ${BASE}/source/i2c-tools_3*
    mkdir -p ${I2_V3_INSTALL_PATH}
    CC=${_CC} LD=${_LD} make
    make install prefix=${I2_V3_INSTALL_PATH}
}

function make_i2c_tools_v3 ()
{
    download_i2c_tools_v3  || return 1
    tar_package  || return 1
    mk_i2c_tools_v3  || return 1
}

############### 4 ###############

download_i2c_tools_v4 () {
    tget https://mirrors.edge.kernel.org/pub/software/utils/i2c-tools/${I2C_TOOLS_V4}.tar.xz
}

mk_i2c_tools_v4 () {
    cd ${BASE}/source/${I2C_TOOLS_V4}
    mkdir -p ${I2_V4_INSTALL_PATH}
    CC=${_CC} LD=${_LD} PREFIX=${I2_V4_INSTALL_PATH} \
        BUILD_DYNAMIC_LIB=0 \
        USE_STATIC_LIB=1 \
        make

    CC=${_CC} LD=${_LD} PREFIX=${I2_V4_INSTALL_PATH} \
        BUILD_DYNAMIC_LIB=0 \
        USE_STATIC_LIB=1 \
        make install
}

function make_i2c_tools_v4 ()
{
    download_i2c_tools_v4  || return 1
    tar_package  || return 1
    mk_i2c_tools_v4  || return 1
}
