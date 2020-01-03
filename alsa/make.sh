##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Mon 02 Sep 2019 11:39:38 AM HKT
##
#!/bin/zsh

BUILD_HOST=arm-linux

BASE=`pwd`
OUTPUT_PATH=${BASE}/install
ALSALIB_DIR=${OUTPUT_PATH}/alsa-lib

make_dirs () {
    #为了方便管理，创建有关的目录
    cd ${BASE} && mkdir compressed install source -p
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
    tget ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.0.22.tar.bz2
    tget ftp://ftp.alsa-project.org/pub/utils/alsa-utils-1.0.22.tar.bz2
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

make_alsa_lib () {
    cd ${BASE}/source/alsa-lib*

     ./configure \
    --host=${BUILD_HOST} \
    --prefix=${OUTPUT_PATH}/alsa-lib \
    --enable-static \
    --enable-shared  \
    --disable-Python \
    --with-configdir=/usr/local/share 
    #--with-plugindir=/usr/local/lib/alsa_lib

    sudo make && sudo make install
}


make_alsa_utils () {
    cd ${BASE}/source/alsa-utils*

    ./configure \
    --host=${BUILD_HOST} \
    --disable-alsamixer  \
    --disable-xmlto \
    CPPFLAGS=-I${ALSALIB_DIR}/include  \
    LDFLAGS=-L${ALSALIB_DIR}/lib  \
    --with-alsa-prefix=${ALSALIB_DIR}/lib  \
    --with-alsa-inc-prefix=${ALSALIB_DIR}/include  \
    --prefix=${OUTPUT_PATH}/alsa-utils

    make && make install
}
echo "Using ${BUILD_HOST}"
make_dirs
download_package
tar_package
make_alsa_lib
make_alsa_utils

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
