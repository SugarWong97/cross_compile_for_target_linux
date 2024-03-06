export X264=x264
export X264_VERSION=${X264}-snapshot-20191217-2245
## for others
X264_FILE_NAME=${X264_VERSION}.tar.bz2
X264_ARCH_PATH=$ROOT_DIR/libx264/compressed/${X264_FILE_NAME}

# 下列有些编译选项可能会影响到编译是否正常，需要结合gcc做确认
export DISABLE_X264_ASM
if [ -z $DISABLE_X264_ASM ];then
export DISABLE_X264_ASM=yes
fi

export DISABLE_X264_OPENCL
if [ -z $DISABLE_X264_OPENCL ];then
export DISABLE_X264_OPENCL=yes
fi

X264_OUTPUT_PATH=${OUTPUT_PATH}/x264

### X264
function get_x264 () {
    if [ -f "$X264_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $X264_ARCH_PATH $ARCHIVE_PATH/$X264_FILE_NAME
        return
    else
        tget http://download.videolan.org/pub/videolan/x264/snapshots/${X264_FILE_NAME}
    fi
}

function _x264_gen_make_sh () {
cat<<EOF
    CC=${_CC} \
    ./configure \
    --host=${BUILD_HOST} \
    --enable-shared \
    --enable-pic \
    --prefix=${X264_OUTPUT_PATH} ${X264_CONFIG_STR_OPENCL} ${X264_CONFIG_STR_ASM} \
    --cross-prefix=${BUILD_HOST_}
EOF
}

function mk_x264() {
    if [ "$DISABLE_X264_ASM" = "yes" ]; then
        X264_CONFIG_STR_ASM="--disable-asm"
    fi
    if [ "$DISABLE_X264_OPENCL" = "yes" ]; then
        X264_CONFIG_STR_OPENCL="--disable-opencl"
    fi
    cd ${BASE}/source/${X264_VERSION}

    _x264_gen_make_sh > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make $MKTHD && make install
}

function make_x264 () {
    get_x264
    tar_package       || return 1
    mk_x264 && return 0
    cat <<EOF
编译失败，请检查下列选项

DISABLE_X264_ASM :
    在低版本的gcc中，也许DISABLE_X264_ASM设为yes更好
    在高版本的gcc中，也许DISABLE_X264_ASM设为no更好
    如果不确定，将当前的配置值("$DISABLE_X264_ASM")取反即可(yes, no)
EOF
}
