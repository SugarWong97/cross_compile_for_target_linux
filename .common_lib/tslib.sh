TSLIB=tslib

export CONFIG_TSLIB_VERSION=1.4
export TSLIB_OUTPUT_PATH=${OUTPUT_PATH}/${TSLIB}

download_tslib () {
    #下载包
    tget https://github.com/libts/tslib/releases/download/${CONFIG_TSLIB_VERSION}/tslib-${CONFIG_TSLIB_VERSION}.tar.bz2
}

do_fix_for_build_tslib () {
    cd ${CODE_PATH}/tslib-${CONFIG_TSLIB_VERSION} || return 1
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

mk_tslib () {
    cd ${CODE_PATH}/tslib-${CONFIG_TSLIB_VERSION} || return 1
    make clean
    make distclean
    echo "ac_cv_func_malloc_0_nonnull=yes" > arm-linux.cache

    CC=${_CC} \
    ./configure --host=arm-linux \
    --prefix=${TSLIB_OUTPUT_PATH} \
    --cache-file=arm-linux.cache  \
    ac_cv_func_malloc_0_nonnull=yes  --enable-inputapi=no
    make  || do_fix_for_build_tslib
    make install
}

make_tslib()
{
    download_tslib
    tar_package
    mk_tslib
}
