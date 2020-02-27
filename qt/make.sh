A##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make_QT5.9.sh
#    Created  :  Fri 22 Nov 2019 11:49:30 AM CST

##
#!/bin/sh
BASE=`pwd`
BUILD_HOST=arm-linux
XPLATFORM=linux-diy-arm-g++

OUTPUT=${BASE}/install/

make_dirs() {
    cd ${BASE}
    mkdir  compressed  install  source -p
}

setup_env () {
    sudo apt-get install autoconf automake autogen libtool libsysfs-dev -y
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
    tget https://github.com/libts/tslib/releases/download/1.4/tslib-1.4.tar.bz2
    tget http://mirrors.ustc.edu.cn/qtproject/archive/qt/5.9/5.9.8/single/qt-everywhere-opensource-src-5.9.8.tar.xz
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

do_fix () {
    cd ${BASE}/source/tslib*
    echo "#define ABS_MT_SLOT            0x2f   /* MT slot being modified */"                >> config.h
    echo "#define ABS_MT_TOUCH_MAJOR     0x30   /* Major axis of touching ellipse */"        >> config.h
    echo "#define ABS_MT_TOUCH_MINOR     0x31   /* Minor axis (omit if circular) */"         >> config.h
    echo "#define ABS_MT_WIDTH_MAJOR     0x32   /* Major axis of approaching ellipse */"     >> config.h
    echo "#define ABS_MT_WIDTH_MINOR     0x33   /* Minor axis (omit if circular) */"         >> config.h
    echo "#define ABS_MT_ORIENTATION     0x34   /* Ellipse orientation */"                   >> config.h
    echo "#define ABS_MT_POSITION_X      0x35   /* Center X touch position */"               >> config.h
    echo "#define ABS_MT_POSITION_Y      0x36   /* Center Y touch position */"               >> config.h
    echo "#define ABS_MT_TOOL_TYPE       0x37   /* Type of touching device */"               >> config.h
    echo "#define ABS_MT_BLOB_ID         0x38   /* Group a set of packets as a blob */"      >> config.h
    echo "#define ABS_MT_TRACKING_ID     0x39   /* Unique ID of initiated contact */"        >> config.h
    echo "#define ABS_MT_PRESSURE        0x3a   /* Pressure on contact area */"              >> config.h
    echo "#define ABS_MT_DISTANCE        0x3b   /* Contact hover distance */"                >> config.h
    echo "#define ABS_MT_TOOL_X          0x3c   /* Center X tool position */"                >> config.h
    echo "#define ABS_MT_TOOL_Y          0x3d   /* Center Y tool position */"                >> config.h
    sed -i 'N;20a\#include \"config.h\"' tools/ts_uinput.c
    make
}

make_tslib () {
    cd ${BASE}/source/tslib*
    make clean
    make distclean
    echo "ac_cv_func_malloc_0_nonnull=yes" > arm-linux.cache

    CC=${BUILD_HOST}-gcc \
    ./configure --host=arm-linux \
    --prefix=${OUTPUT}/tslib \
    --cache-file=arm-linux.cache  \
    ac_cv_func_malloc_0_nonnull=yes  --enable-inputapi=no
    make  || do_fix
    make install
}

pre_configure_xplatform () {
    cd ${BASE}/source/qt*
    [ -d  qtbase/mkspecs/${XPLATFORM} ] && rm qtbase/mkspecs/${XPLATFORM} -r
    cp qtbase/mkspecs/linux-arm-gnueabi-g++ -r qtbase/mkspecs/${XPLATFORM}
    cd qtbase/mkspecs/${XPLATFORM}

    # qmake.conf
    sed -r -i "/QMAKE_CC/ s/.*/QMAKE_CC \t\t= ${BUILD_HOST}-gcc/"               qmake.conf
    sed -r -i "/QMAKE_CXX/ s/.*/QMAKE_CXX \t\t= ${BUILD_HOST}-g++/"             qmake.conf
    sed -r -i "/QMAKE_LINK / s/.*/QMAKE_LINK \t\t= ${BUILD_HOST}-g++/"          qmake.conf
    sed -r -i "/QMAKE_LINK_SHLIB/ s/.*/QMAKE_LINK_SHLIB \t= ${BUILD_HOST}-g++/" qmake.conf

    sed -r -i "/QMAKE_AR/ s/.*/QMAKE_AR \t\t= ${BUILD_HOST}-ar cqs/"            qmake.conf
    sed -r -i "/QMAKE_OBJCOPY/ s/.*/QMAKE_OBJCOPY \t\t= ${BUILD_HOST}-objcopy/" qmake.conf
    sed -r -i "/QMAKE_NM/ s/.*/QMAKE_NM \t\t= ${BUILD_HOST}-nm -P/"             qmake.conf
    sed -r -i "/QMAKE_STRIP/ s/.*/QMAKE_STRIP \t\t= ${BUILD_HOST}-strip/"       qmake.conf

    #sed -i 'N;20a\QMAKE_INCDIR += ${OUTPUT}/tslib/include' qmake.conf
    #sed -i 'N;20a\QMAKE_LIBDIR += ${OUTPUT}/tslib/lib'     qmake.conf
    
}


configure_qt () {
    cd ${BASE}/source/qt*
    ./configure \
    -v \
    -prefix ${OUTPUT}/qt \
    -release \
    -opensource \
    -confirm-license \
    -xplatform ${XPLATFORM} \
    -nomake examples -nomake tools \
    -optimized-qmake \
    -no-cups \
    -pch \
    -qt-zlib \
    -qt-sqlite \
    -tslib \
    -no-opengl \
    -no-sse2 \
    -no-openssl \
    -no-glib \
    -no-cups \
    -recheck-all \
    -no-separate-debug-info \
    -no-pkg-config \
    -skip qt3d \
    -skip qtcanvas3d \
    -skip qtdeclarative \
    -no-iconv \
    -I${OUTPUT}/tslib/include  -L${OUTPUT}/tslib/lib | tee ${BASE}/install/qt_configure_information
}

make_qt () {
    cd ${BASE}/source/qt*
    make -j4 && make install
}

make_dirs
setup_env
download_package
tar_package
make_tslib
pre_configure_xplatform
configure_qt
make_qt
