export X264=x264
export CONFIG_X264_VERSION=snapshot-20191217-2245
export X264_VERSION=${X264}-${CONFIG_X264_VERSION}
## for others
export X264_FILE_NAME=${X264_VERSION}.tar.bz2
export X264_ARCH_PATH=$ROOT_DIR/libx264/compressed/${X264_FILE_NAME}

# 下列有些编译选项可能会影响到编译是否正常，需要结合gcc做确认
### 通过y/n来配置libx264是否启用ASM（默认禁用）
export USING_X264_ASM
### 通过y/n来配置libx264是否启用OPENCL（默认禁用）
export USING_X264_OPENCL

export X264_OUTPUT_PATH=${OUTPUT_PATH}/x264
export X264_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/x264

function _sync_export_var_x264()
{
    export X264_VERSION=${X264}-${CONFIG_X264_VERSION}
    export X264_FILE_NAME=${X264_VERSION}.tar.bz2
    export X264_ARCH_PATH=$ROOT_DIR/libx264/compressed/${X264_FILE_NAME}
}

### X264
function get_x264 () {
    _sync_export_var_x264
    tget_package_from_arch $X264_ARCH_PATH  $ARCHIVE_PATH/$X264_FILE_NAME http://download.videolan.org/pub/videolan/x264/snapshots/${X264_FILE_NAME}
}

function _x264_gen_make_sh () {
    local for_host="$1"
    local config_args_add=""
    if [ -z "$for_host" ];then
        read -r -d '' config_args_add <<- EOF
    CC=${_CC} \
    --prefix=${X264_OUTPUT_PATH} \
    --host=${BUILD_HOST} \
    --cross-prefix=${BUILD_HOST_}
EOF
    else
        config_args_add="--prefix=${X264_OUTPUT_PATH_HOST} "
    fi
    if [ "$USING_X264_ASM" = "y" ];then
        export X264_ASM_DIS="no"
    else
        export X264_ASM_DIS="yes"
    fi

    if [ "$USING_X264_OPENCL" = "y" ];then
        export X264_OPENCL_DIS=yes
    else
        export X264_OPENCL_DIS="no"
    fi


    if [ "$X264_ASM_DIS" = "yes" ]; then
        X264_CONFIG_STR_ASM="--disable-asm"
    else
        X264_CONFIG_STR_ASM=""
    fi
    if [ "$X264_OPENCL_DIS" = "yes" ]; then
        X264_CONFIG_STR_OPENCL="--disable-opencl"
    fi
cat<<EOF
    echo ""
    echo "Making libx264.."
    echo ""
    sleep 1
    ./configure \
    --enable-shared \
    --enable-pic  ${config_args_add} \
     ${X264_CONFIG_STR_OPENCL} ${X264_CONFIG_STR_ASM}
EOF
}
function _x264_gen_make_sh_host () {
    _x264_gen_make_sh y
}

function mk_x264() {
    _sync_export_var_x264
    cd ${BASE}/source/${X264_VERSION}

    _x264_gen_make_sh > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make $MKTHD CC=${_CC} || return 1
    make install
}

function mk_x264_host () {
    _sync_export_var_x264
    cd ${BASE}/source/${X264_VERSION}

    _x264_gen_make_sh_host > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make $MKTHD CC=gcc  || return 1
    make install
}

function print_x264_fail_info ()
{
    cat <<EOF
编译失败，请检查下列选项

USING_X264_ASM :
    在低版本的gcc中，也许USING_X264_ASM设为y更好
    在高版本的gcc中，也许USING_X264_ASM设为n更好
    如果不确定，将当前的配置值("${USING_X264_ASM}")取反即可(y, n)
EOF
}

function make_x264 () {
    _sync_export_var_x264
    get_x264
    tar_package       || return 1
    mk_x264 && return 0
    export USING_X264_ASM
    if [ "$USING_X264_ASM" != "y" ];then
        export USING_X264_ASM="y"
    else
        export USING_X264_ASM="y"
    fi
    echo "Remake X264 with !USING_X264_ASM : $USING_X264_ASM"
    mk_x264 && return 0
    print_x264_fail_info
    return 1
}

function make_x264_host () {
    _sync_export_var_x264
    get_x264
    tar_package       || return 1
    mk_x264_host && return 0
    export USING_X264_ASM
    if [ "$USING_X264_ASM" != "y" ];then
        export USING_X264_ASM="y"
    else
        export USING_X264_ASM="y"
    fi
    echo "Remake X264 with !USING_X264_ASM : $USING_X264_ASM"
    mk_x264_host && return 0
    print_x264_fail_info
    return 1
}
