#!/bin/bash

WPA_SUPPLICANT=wpa_supplicant
CONFIG_WPA_SUPPLICANT_VERSION=0.7.3
export WPA_SUPPLICANT_VERSION=${WPA_SUPPLICANT}-${CONFIG_WPA_SUPPLICANT_VERSION}
export WPA_SUPPLICANT_OUTPUT_PATH=${OUTPUT_PATH}/${WPA_SUPPLICANT}

download_wpa_supplicant () {
    get_ssl
    tget  http://w1.fi/releases/${WPA_SUPPLICANT_VERSION}.tar.gz
}

mk_wpa_supplicant () {
    cd ${CODE_PATH}/${WPA_SUPPLICANT_VERSION}/wpa_supplicant
    cp defconfig .config
    (
cat <<EOF
CC=${_CC} -L${OPENSSL_OUTPUT_PATH}/lib
CFLAGS += -I${OPENSSL_OUTPUT_PATH}/include
LIBS += -L${OPENSSL_OUTPUT_PATH}/lib
EOF
)  >> .config
    make || return 1
    make install DESTDIR=${WPA_SUPPLICANT_OUTPUT_PATH}
    cp ${CODE_PATH}/${WPA_SUPPLICANT_VERSION}/wpa_supplicant/examples/wpa-psk-tkip.conf ${OUTPUT_PATH}/wpa_supplicant/wpa.conf
    # 在ctrl_interface 当前行下插入 update_config=1
    sed -i '/ctrl_interface/aupdate_config=1' ${WPA_SUPPLICANT_OUTPUT_PATH}/wpa.conf
}

make_wpa_supplicant () {
    export WPA_SUPPLICANT_VERSION=${WPA_SUPPLICANT}-${CONFIG_WPA_SUPPLICANT_VERSION}
    download_wpa_supplicant

    tar_package
    mk_ssl
    mk_wpa_supplicant
}
