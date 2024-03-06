#!/bin/sh
WPA_SUPPLICANT=wpa_supplicant-0.7.3

download_wpa_supplicant () {
    get_ssl
    tget  http://w1.fi/releases/${WPA_SUPPLICANT}.tar.gz
}

mk_wpa_supplicant () {
    cd ${CODE_PATH}/${WPA_SUPPLICANT}/wpa_supplicant
    cp defconfig .config
    (
cat <<EOF
CC=${_CC} -L${OUTPUT_PATH}/${OPENSSL}/lib
CFLAGS += -I${OUTPUT_PATH}/${OPENSSL}/include
LIBS += -L${OUTPUT_PATH}/${OPENSSL}/lib
EOF
)  >> .config
    make || return 1
    make install DESTDIR=${OUTPUT_PATH}/wpa_supplicant/
    cp ${CODE_PATH}/${WPA_SUPPLICANT}/wpa_supplicant/examples/wpa-psk-tkip.conf ${OUTPUT_PATH}/wpa_supplicant/wpa.conf
    # 在ctrl_interface 当前行下插入 update_config=1
    sed -i '/ctrl_interface/aupdate_config=1' ${OUTPUT_PATH}/wpa_supplicant/wpa.conf
}

make_wpa_supplicant () {
    download_wpa_supplicant

    tar_package
    mk_ssl
    mk_wpa_supplicant
}
