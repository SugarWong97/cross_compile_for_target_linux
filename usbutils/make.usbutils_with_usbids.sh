##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
##
#!/bin/sh

source ../.common


USBUTILS_INSTALL=${OUTPUT_PATH}/usbutils
LIBUSB_INSTALL=${OUTPUT_PATH}/libusb
LIBUSB_COMPAT_INSTALL=${OUTPUT_PATH}/libusb-compat
USBIDS_PATH=/usr/share/

LIBUSB_VERSION=1.0.26
LIBUSB_COMPAT_VERSION=0.1.8
# 目前支持 007 及以下的版本
# 007 ~ 001, 0.91 ~ 0.90, 0.81 ~ 0.80
#USBUTILS_VERSION=007
USBUTILS_VERSION=0.80


USBUTILS=usbutils-${USBUTILS_VERSION}
LIBUSB_COMPAT=libusb-compat-${LIBUSB_COMPAT_VERSION}
LIBUSB=libusb-${LIBUSB_VERSION}

echo $USBUTILS

#下载包
download_usbutils () {

    #https://github.com/libusb/libusb/releases/download/v1.0.26/libusb-1.0.26.tar.bz2
    tget https://github.com/libusb/libusb/releases/download/v${LIBUSB_VERSION}/libusb-${LIBUSB_VERSION}.tar.bz2

    #https://github.com/libusb/libusb-compat-0.1/releases/download/v0.1.8/libusb-compat-0.1.8.tar.gz
    tget https://github.com/libusb/libusb-compat-0.1/releases/download/v${LIBUSB_COMPAT_VERSION}/libusb-compat-${LIBUSB_COMPAT_VERSION}.tar.bz2

    tget_and_rename https://github.com/gregkh/usbutils/archive/refs/tags/v${USBUTILS_VERSION}.tar.gz ${USBUTILS}.tar.gz
}

make_libusb () {
    cd ${CODE_PATH}/${LIBUSB} || return 1
bash <<EOF
    ./autogen.sh
     ./configure \
    --host=${BUILD_HOST} \
    --prefix=${LIBUSB_INSTALL} \
    --disable-udev  && make -j8 && make install
EOF
}

make_libusb_compat () {
    cd ${CODE_PATH}/${LIBUSB_COMPAT} || return 1
    #cp -r ${LIBUSB_INSTALL}/include/* libusb
    #cp -r ${LIBUSB_INSTALL}/lib/* libusb

    #cp -r ${LIBUSB_INSTALL}/include/* .
    #cp -r ${LIBUSB_INSTALL}/lib/* .
bash <<EOF
    export LIBUSB_1_0_CFLAGS="-I${LIBUSB_INSTALL}/include/libusb-1.0 -L${LIBUSB_INSTALL}/lib"
    export LIBUSB_1_0_LIBS="-L${LIBUSB_INSTALL}/lib"
    export CFLAGS="-g -O2 ${LIBUSB_1_0_CFLAGS} $LIBUSB_1_0_LIBS"
    ./autogen.sh
     ./configure \
         CFLAGS=${CFLAGS} \
    --host=${BUILD_HOST} \
    --prefix=${LIBUSB_COMPAT_INSTALL} && make -j8 CFLAGS=${CFLAGS} && make install
EOF
}

make_usbutils () {
    cd ${CODE_PATH}/${USBUTILS} || return 1
    #${_CC} *.c -L../../install/libusb-compat/lib/ -I../../install/libusb-compat/include/ -I../../install/libusb/include/libusb-1.0/ -L../../install/libusb/lib  ../../install/libusb-compat/lib/libusb.a ../../install/libusb/lib/libusb-1.0.a -lpthread -o ~/share_nfs/lsusb

    #Gen config.h
    (
    cat <<EOF
#ifndef __CONFIG_H__
#define __CONFIG_H__
#define PACKAGE "usbutils"
#define VERSION "$USBUTILS_VERSION"
#define DATADIR "$USBIDS_PATH"
#endif /* __CONFIG_H__ */
EOF
    ) > config.h

    # Build lsusb
    GCC_FLAG="-L${LIBUSB_COMPAT_INSTALL}/lib  -I${LIBUSB_COMPAT_INSTALL}/include  -I${LIBUSB_INSTALL}/include/libusb-1.0/ -L${LIBUSB_INSTALL}/lib"
    USING_LIBS="${LIBUSB_COMPAT_INSTALL}/lib/libusb.a ${LIBUSB_INSTALL}/lib/libusb-1.0.a"
    mkdir -p ${USBUTILS_INSTALL}/bin
    ${_CC} *.c ${GCC_FLAG} ${USING_LIBS}  -lpthread -o ${USBUTILS_INSTALL}/bin/lsusb || { echo >&2 "Aborted : Error."; exit 1; }

    # Copy usb.ids
    # cp usb.ids ${USBUTILS_INSTALL} # from cur-repo
    IDS=`ls ${BASE}/meta/ | tail -n 1`
    cp -v ${BASE}/meta/$IDS  ${USBUTILS_INSTALL}/usb.ids


    (
    cat <<EOF

Build OK

Copy "usb.ids" to <$USBIDS_PATH> before run 'lsusb'
version : $IDS
EOF
    ) | tee ${USBUTILS_INSTALL}/usb.ids.txt
#bash <<EOF
#    export LIBUSB_CFLAGS="-I${LIBUSB_INSTALL}/include/ -I${LIBUSB_COMPAT_INSTALL}/include -L${LIBUSB_INSTALL}/lib -l${LIBUSB_COMPAT_INSTALL}/lib"
#    export LIBUSB_LIBS="-L${LIBUSB_INSTALL}/lib -l${LIBUSB_COMPAT_INSTALL}/lib"
#    export CFLAGS="-g -O2 ${LIBUSB_1_0_CFLAGS} $LIBUSB_1_0_LIBS"
#    ./autogen.sh
#     ./configure \
#    --host=${BUILD_HOST} \
#    --prefix=${USBUTILS_INSTALL} \
#    --disable-libudev BUG: disable libudev but Can not help requiring libudev
#    --disable-udev    BUG: disable libudev but Can not help requiring libudev
#EOF

}
#sudo apt-get install -y autoconf
require autoreconf   || return 1

#sudo apt-get install -y libtoo
require libtoolize   || return 1

mk_usbutils ()
{
    make_dirs
    download_usbutils|| { echo >&2 "download_usbutils "; exit 1; }
    tar_package
    make_libusb
    make_libusb_compat
    make_usbutils
}
mk_usbutils
