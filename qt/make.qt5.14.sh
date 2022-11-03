##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.qt5.14.sh

##
#!/bin/bash

source ../.common

BASE=`pwd`
XPLATFORM=linux-diy-arm-g++

OUTPUT=${BASE}/install/

setup_env () {
    #sudo apt-get install autoconf automake autogen libtool libsysfs-dev -y
    echo "Skip"
}

download_package () {
    cd ${BASE}/compressed
    #下载包
    tget https://github.com/libts/tslib/releases/download/1.4/tslib-1.4.tar.bz2
    tget https://download.qt.io/archive/qt/5.14/5.14.2/single/qt-everywhere-src-5.14.2.tar.xz
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

    CC=${BUILD_HOST_}gcc \
    ./configure --host=arm-linux \
    --prefix=${OUTPUT}/tslib \
    --cache-file=arm-linux.cache  \
    ac_cv_func_malloc_0_nonnull=yes  --enable-inputapi=no
    make  || do_fix
    make install
}

pre_configure_xplatform () {
    cd ${BASE}/source/qt*5.14*
    [ -d  qtbase/mkspecs/${XPLATFORM} ] && rm qtbase/mkspecs/${XPLATFORM} -r
    cp qtbase/mkspecs/linux-arm-gnueabi-g++ -r qtbase/mkspecs/${XPLATFORM}
    cd qtbase/mkspecs/${XPLATFORM}

    # qmake.conf
    sed -r -i "/QMAKE_CC/ s/.*/QMAKE_CC \t\t= ${BUILD_HOST_}gcc/"               qmake.conf
    sed -r -i "/QMAKE_CXX/ s/.*/QMAKE_CXX \t\t= ${BUILD_HOST_}g++/"             qmake.conf
    sed -r -i "/QMAKE_LINK / s/.*/QMAKE_LINK \t\t= ${BUILD_HOST_}g++/"          qmake.conf
    sed -r -i "/QMAKE_LINK_SHLIB/ s/.*/QMAKE_LINK_SHLIB \t= ${BUILD_HOST_}g++/" qmake.conf

    sed -r -i "/QMAKE_AR/ s/.*/QMAKE_AR \t\t= ${BUILD_HOST_}ar cqs/"            qmake.conf
    sed -r -i "/QMAKE_OBJCOPY/ s/.*/QMAKE_OBJCOPY \t\t= ${BUILD_HOST_}objcopy/" qmake.conf
    sed -r -i "/QMAKE_NM/ s/.*/QMAKE_NM \t\t= ${BUILD_HOST_}nm -P/"             qmake.conf
    sed -r -i "/QMAKE_STRIP/ s/.*/QMAKE_STRIP \t\t= ${BUILD_HOST_}strip/"       qmake.conf
    sed -r -i '3a\QT_QPA_DEFAULT_PLATFORM = linuxfb'                           qmake.conf
    sed -r -i '3a\QT_QPA_PLATFORM = linuxfb'                                   qmake.conf

    #sed -i 'N;20a\QMAKE_INCDIR += ${OUTPUT}/tslib/include' qmake.conf
    #sed -i 'N;20a\QMAKE_LIBDIR += ${OUTPUT}/tslib/lib'     qmake.conf

}

configure_qt_with_tslib () {
    cd ${BASE}/source/qt*5.14*
    ./configure \
    -v \
    -prefix ${OUTPUT}/qt \
    -release \
    -qt-libpng -qt-libjpeg \
    -opensource \
    -confirm-license \
    -make libs \
    -xplatform ${XPLATFORM} \
    -no-opengl -no-ico -shared \
    -nomake examples -nomake tools -nomake tests \
    -linuxfb \
    -qt-freetype \
    -optimized-qmake \
    -widgets \
    -no-cups \
    -no-accessibility \
    -no-dbus \
    -pch \
    -qt-zlib \
    -qt-sqlite \
    -no-sse2 \
    -no-openssl \
    -no-glib \
    -no-cups \
    -recheck-all \
    -no-separate-debug-info \
    -no-pkg-config \
    -skip qt3d \
    -tslib \
    -I${OUTPUT}/tslib/include  -L${OUTPUT}/tslib/lib \
    -skip qtcanvas3d \
    -skip qtdeclarative \
    -no-iconv \
    2>&1 | tee ${BASE}/install/.qt.configure.log
# -plugin-sql-sqlite \
#   -strip \
#    -no-opengl -no-ico -strip -shared \
}

configure_qt_without_tslib () {
    cd ${BASE}/source/qt*5.14*
    ./configure \
    -v \
    -prefix ${OUTPUT}/qt \
    -release \
    -qt-libpng -qt-libjpeg \
    -opensource \
    -confirm-license \
    -make libs \
    -xplatform ${XPLATFORM} \
    -no-opengl -no-ico -shared \
    -nomake examples -nomake tools -nomake tests \
    -linuxfb \
    -qt-freetype \
    -optimized-qmake \
    -widgets \
    -no-cups \
    -no-accessibility \
    -no-dbus \
    -pch \
    -qt-zlib \
    -qt-sqlite \
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
    2>&1 | tee ${BASE}/install/.qt.configure.log
# -plugin-sql-sqlite \
#   -strip \
}

make_qt () {
    cd ${BASE}/source/qt*5.14*
    make -j32   2>&1 | tee ${BASE}/install/.qt.make.log && make install
}

make_profile ()
{
cat <<EOF
#
##############################ts lib##############################

export TS_ROOT=/usr/tslib1.4
export TSDEVICE=/dev/input/event1

export TSLIB_CONFFILE=\$TS_ROOT/etc/ts.conf
export TSLIB_PLUGINDIR=\$TS_ROOT/lib/ts
export TSLIB_TSDEVICE=\$TSDEVICE
export TSLIB_CALIBFILE=/etc/pointercal
export TSLIB_CONSOLEDEVICE=none
export TSLIB_FBDEVICE=/dev/fb0

export LD_LIBRARY_PATH=\$TS_ROOT/lib:\$LD_LIBRARY_PATH

##############################QT ##############################

## QT DEBUG
export QT_DEBUG_PLUGINS=1
export QT_ROOT=/usr/qt
export QT_ROOT=/root/temp_dir/qt

## No such plugin for spec "tslib"
# export QT_QPA_GENERIC_PLUGINS=tslib:\${TSDEVICE}
# export QT_QPA_GENERIC_PLUGINS=evdevkeyboard:/dev/input/event0,evdevmouse:/dev/input/mouse0
export QT_QPA_GENERIC_PLUGINS=evdevkeyboard:/dev/input/event0

# need to add
export QT_QPA_FONTDIR=\$QT_ROOT/fonts
export QT_QPA_PLATFORM_PLUGIN_PATH=\$QT_ROOT/plugins
export QT_PLUGIN_PATH=\$QT_ROOT/plugins
#export QT_QPA_PLATFORM_PATH=\$QT_ROOT/plugins
export QT_QPA_PLATFORM=linuxfb:tty=/dev/fb0
#export QT_QPA_PLATFORM=linuxfb:fb=/dev/fb0:size=1024x768:mmSize=1024x768:offset=0x0:tty=/dev/tty1

export QT_QPA_FB_TSLIB=1
## For QML
export QML2_IMPORT_PATH=\$QT_ROOT/qml
#export QMLSCENE_DEVICE=softwarecontext

## OS-ENV about QT
export LD_LIBRARY_PATH=\$QT_ROOT/lib:\$QT_ROOT/plugins/platforms:\$LD_LIBRARY_PATH
export PATH=\$QT_ROOT/bin:\$PATH
EOF
}

make_dirs
setup_env
download_package
tar_package
pre_configure_xplatform

#make_tslib
#configure_qt_with_tslib
configure_qt_without_tslib

make_qt
make_profile > $OUTPUT/qt.profile
