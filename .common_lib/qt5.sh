## 默认启用tslib，禁用时设n即可
export USING_TSLIB_FOR_QT

export CONFIG_QT_VERSION=5.15.14
export QT_OUTPUT_PATH=${OUTPUT_PATH}/qt

XPLATFORM_FOR_QT=linux-diy-arm-g++

set_qt ()
{
    if [ "$USING_TSLIB_FOR_QT" = "n" ];then
        export TSLIB_FOR_QT="no"
    else
        export TSLIB_FOR_QT="yes"
    fi
}

download_qt_package () {
    set_qt
    local qt_version_maj=`echo $CONFIG_QT_VERSION | grep -oP '\d*\.\d+' | head -n 1`
    #下载包
    if [ "$TSLIB_FOR_QT" = "yes" ];then
        download_tslib
    fi
    tget https://linorg.usp.br/Qt/archive/qt/${qt_version_maj}/${CONFIG_QT_VERSION}/single/${CONFIG_QT_DOWNLOAD_URL_PRE}-${CONFIG_QT_VERSION}.tar.xz
    tget https://github.com/liberationfonts/liberation-fonts/files/7261482/liberation-fonts-ttf-2.1.5.tar.gz
}

pre_configure_xplatform () {
    cd ${CODE_PATH}/qt*${CONFIG_QT_VERSION}*
    [ -d  qtbase/mkspecs/${XPLATFORM_FOR_QT} ] && rm qtbase/mkspecs/${XPLATFORM_FOR_QT} -r
    cp qtbase/mkspecs/linux-arm-gnueabi-g++ -r qtbase/mkspecs/${XPLATFORM_FOR_QT}
    cd qtbase/mkspecs/${XPLATFORM_FOR_QT}

    # qmake.conf
    sed -r -i "/QMAKE_CC/ s/.*/QMAKE_CC \t\t= ${BUILD_HOST_}gcc/"                qmake.conf
    sed -r -i "/QMAKE_CXX/ s/.*/QMAKE_CXX \t\t= ${BUILD_HOST_}g++/"              qmake.conf
    sed -r -i "/QMAKE_LINK / s/.*/QMAKE_LINK \t\t= ${BUILD_HOST_}g++/"           qmake.conf
    sed -r -i "/QMAKE_LINK_SHLIB/ s/.*/QMAKE_LINK_SHLIB \t= ${BUILD_HOST_}g++/"  qmake.conf

    sed -r -i "/QMAKE_AR/ s/.*/QMAKE_AR \t\t= ${BUILD_HOST_}ar cqs/"             qmake.conf
    sed -r -i "/QMAKE_OBJCOPY/ s/.*/QMAKE_OBJCOPY \t\t= ${BUILD_HOST_}objcopy/"  qmake.conf
    sed -r -i "/QMAKE_NM/ s/.*/QMAKE_NM \t\t= ${BUILD_HOST_}nm -P/"              qmake.conf
    sed -r -i "/QMAKE_STRIP/ s/.*/QMAKE_STRIP \t\t= ${BUILD_HOST_}strip/"        qmake.conf
    sed -r -i '3a\QT_QPA_DEFAULT_PLATFORM = linuxfb'                             qmake.conf
    sed -r -i '3a\QT_QPA_PLATFORM = linuxfb'                                     qmake.conf

    #sed -i 'N;20a\QMAKE_INCDIR += ${OUTPUT}/tslib/include' qmake.conf
    #sed -i 'N;20a\QMAKE_LIBDIR += ${OUTPUT}/tslib/lib'     qmake.conf

}

configure_qt () {
    local tslib_opt=""
    if [ "$TSLIB_FOR_QT" = "yes" ];then
        tslib_opt="-tslib  -I${TSLIB_OUTPUT_PATH}/include  -L${TSLIB_OUTPUT_PATH}/lib"
    fi
    cd ${CODE_PATH}/qt*${CONFIG_QT_VERSION}*
    ./configure \
    -v \
    -release \
    -opensource \
    -no-accessibility \
    -make libs \
    -xplatform ${XPLATFORM_FOR_QT} \
    -optimized-qmake \
    -pch \
    -qt-zlib \
    -qt-freetype \
    -skip qtlocation \
    -no-iconv \
    -no-opengl \
    -nomake tests  \
    -no-openssl \
    -no-cups \
    -no-glib \
    -no-pkg-config \
    -no-separate-debug-info \
    -prefix ${QT_OUTPUT_PATH} \
    -qt-libpng -qt-libjpeg \
    -confirm-license \
    -no-opengl -no-ico -shared  \
    -linuxfb \
    -widgets \
    -no-dbus \
    -qt-sqlite \
    -no-sse2 \
    -no-openssl \
    -no-glib \
    -recheck-all \
    -no-separate-debug-info \
    -no-pkg-config \
    -skip qt3d $tslib_opt \
    -skip qtcanvas3d \
    -skip qtdeclarative \
    2>&1 | tee ${BASE}/install/.qt.configure.log
# -plugin-sql-sqlite \
#   -strip \
#   -nomake examples -nomake tools -nomake tests \
#    -no-opengl -no-ico -strip -shared \
}

mk_qt () {
    cd ${CODE_PATH}/qt*${CONFIG_QT_VERSION}*
    make -j32   2>&1 | tee ${BASE}/install/.qt.make.log && make install
}

make_qt_profile ()
{
    if [ "$TSLIB_FOR_QT" = "yes" ];then
cat <<EOF
##############################ts lib##############################

export TS_ROOT=/usr/tslib
export TSDEVICE=/dev/input/event0

export TSLIB_CONFFILE=\$TS_ROOT/etc/ts.conf
export TSLIB_PLUGINDIR=\$TS_ROOT/lib/ts
export TSLIB_TSDEVICE=\$TSDEVICE
export TSLIB_CALIBFILE=/etc/pointercal
export TSLIB_CONSOLEDEVICE=none
export TSLIB_FBDEVICE=/dev/fb0

export LD_LIBRARY_PATH=\$TS_ROOT/lib:\$LD_LIBRARY_PATH

touch \$TSLIB_CALIBFILE
EOF
    fi
cat <<EOF
############################## QT ##############################

## QT DEBUG
export QT_DEBUG_PLUGINS=1
export QT_ROOT=/usr/qt

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
##############################    ##############################
EOF
}
make_qt()
{
    set_qt
    download_qt_package
    tar_package
    pre_configure_xplatform

    if [ "$TSLIB_FOR_QT" = "yes" ];then
        make_tslib
    fi
    configure_qt

    mk_qt
    make_qt_profile > $OUTPUT_PATH/qt.profile
}
