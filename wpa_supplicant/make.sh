##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
#    Created  :  Tue 10 Dec 2019 05:42:56 PM CST
#!/bin/sh
BUILD_HOST=arm-linux
ARM_GCC=${BUILD_HOST}-gcc
BASE=`pwd`
OUTPUT_PATH=${BASE}/install
OPENSSL=openssl-1.0.2t
WPA_SUPPLICANT=wpa_supplicant-0.7.3

make_dirs() {
    cd ${BASE}
    mkdir  compressed  install  source -p
}

tget () { #try wget
    filename=`basename $1`
    echo "Downloading [${filename}]..."
    if [ ! -f ${filename} ];then
        wget $1
    fi

    echo "[OK] Downloaded [${filename}] "
}

download_package () {
    cd ${BASE}/compressed
    #下载包
    wget  https://www.openssl.org/source/${OPENSSL}.tar.gz
    tget  http://w1.fi/releases/${WPA_SUPPLICANT}.tar.gz
}

tar_package () {
    cd ${BASE}/compressed
    ls * > /tmp/list.txt
    for TAR in `cat /tmp/list.txt`
    do
        tar -xf $TAR -C  ../source
    done
    rm -rf /tmp/list.txt
}

pre_make_ssl () {
    cd ${BASE}/source/${OPENSSL}
    startLine=`sed -n '/install_html_docs\:/=' Makefile |  awk -F\b '{ print $1 }'`
    echo $startLine
    # 为了避免 多行结果
    for startline in $startLine
    do
        lineAfter=99
        endLine=`expr $startline + 999`
        sed -i $startline','$endLine'd' Makefile
        echo "install_html_docs:" >> Makefile
        echo "\t@echo skip by Schips" >> Makefile
        echo "install_docs:" >> Makefile
        echo "\t@echo skip by Schips" >> Makefile
        echo "# DO NOT DELETE THIS LINE -- make depend  depends on it." >> Makefile
        break
    done
}

make_openssl () {
    cd ${BASE}/source/${OPENSSL}
    echo "SSL ABOUT"
        ./Configure --prefix=${OUTPUT_PATH}/${OPENSSL}  os/compiler:${ARM_GCC}
    pre_make_ssl
    make && make install
}

make_wpa () {
    cd ${BASE}/source/wpa*/wpa*
    cp defconfig .config
    echo "CC=${ARM_GCC} -L${OUTPUT_PATH}/${OPENSSL}/lib"  >> .config
    echo "CFLAGS += -I${OUTPUT_PATH}/${OPENSSL}/include"  >> .config
    echo "LIBS += -L${OUTPUT_PATH}/${OPENSSL}/lib" >>  .config
    make && make install DESTDIR=${BASE}/install/wpa_supplicant/
    cp ${BASE}/source/wpa*/wpa*/examples/wpa-psk-tkip.conf ${BASE}/install/wpa_supplicant/wpa.conf
    # 在ctrl_interface 当前行下插入 update_config=1
    sed -i '/ctrl_interface/aupdate_config=1' ${BASE}/install/wpa_supplicant/wpa.conf
}

make_dirs
download_package
tar_package
make_openssl
make_wpa
