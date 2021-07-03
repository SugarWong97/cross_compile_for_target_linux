##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Mon 02 Sep 2019 11:39:38 AM HKT
##
#!/bin/zsh

source ../.common

ALSALIB_DIR=${OUTPUT_PATH}/alsa-lib

download_package () {
    cd ${BASE}/compressed
    tget ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.0.22.tar.bz2
    tget ftp://ftp.alsa-project.org/pub/utils/alsa-utils-1.0.22.tar.bz2
}

function make_alsa_lib () {
function _make_sh () {
cat<<EOF
     ./configure \
    --host=${BUILD_HOST} \
    --prefix=${ALSALIB_DIR} \
    --enable-static \
    --enable-shared  \
    --disable-mixer \
    --disable-Python \
    --with-configdir=${ALSALIB_DIR}/share 
EOF
    #--with-plugindir=/usr/local/lib/alsa_lib
}
    cd ${BASE}/source/alsa-lib*

    _make_sh > $tmp_config
    source ./$tmp_config
    make clean
    make  $MKTHD && make install
}


function make_alsa_utils () {
function _make_sh () {
cat<<EOF
    ./configure \
    --host=${BUILD_HOST} \
    --disable-alsamixer  \
    --disable-xmlto \
    CPPFLAGS=-I${ALSALIB_DIR}/include  \
    LDFLAGS=-L${ALSALIB_DIR}/lib  \
    --with-alsa-prefix=${ALSALIB_DIR}/lib  \
    --with-alsa-inc-prefix=${ALSALIB_DIR}/include  \
    --prefix=${OUTPUT_PATH}/alsa-utils
EOF
}
    cd ${BASE}/source/alsa-utils*

    _make_sh > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make  $MKTHD && make install
}

function make_build ()
{
    download_package || return 1
    tar_package || return 1
    make_alsa_lib || return 1
    make_alsa_utils || return 1
}
make_build || echo "Err"
exit $?
以下内容针对板子

#!/bin/sh

mkdir /dev/snd
cd /dev/snd

mknod mixer c 14 0
mknod dsp   c 14 3
mknod audio c 14 4

mknod controlC0 c 116 0
mknod seq       c 116 1

mknod pcmC0D0p c 116 16
mknod pcmC0D1p c 116 17
mknod pcmC0D0c c 116 24
mknod pcmC0D1c c 116 25

mknod timer    c 116 33
