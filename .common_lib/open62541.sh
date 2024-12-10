
export CONFIG_OPEN62541_VERSION=1.4.8
export OPEN62541_OUTPUT_PATH=${OUTPUT_PATH}/open62541
export OPEN62541_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/open62541

export BUILD_OPEN62541_FOR_HOST
export BUILD_OPEN62541_FOR_TARGET

set_open62541()
{
    if [ "$BUILD_OPEN62541_FOR_HOST" = "n" ];then
        export OPEN62541_FOR_HOST="no"
    else
        export OPEN62541_FOR_HOST="yes"
    fi

    if [ "$BUILD_OPEN62541_FOR_TARGET" = "n" ];then
        export OPEN62541_FOR_TARGET="no"
    else
        export OPEN62541_FOR_TARGET="yes"
    fi
}

download_open62541_package () {
    tget_and_rename https://github.com/open62541/open62541/archive/refs/tags/v${CONFIG_OPEN62541_VERSION}.tar.gz open62541-${CONFIG_OPEN62541_VERSION}.tar.gz
}

mk_open62541()
{
    local build_for="$1" # host or target
    cd ${CODE_PATH}/open62541-$CONFIG_OPEN62541_VERSION

    if [ "$build_for" = "host" ];then
        tmp_open62541_output_path=$OPEN62541_OUTPUT_PATH_HOST
    else
        tmp_open62541_output_path=$OPEN62541_OUTPUT_PATH
    fi

    bash <<EOF
    tmp_open62541_output_path="$OPEN62541_OUTPUT_PATH"

    rm build/ -rf
    mkdir -p build

    if [ "$build_for" = "target" ];then
        export CC=${_CC}
        export CXX=${_CXX}
        export AR=${_AR}
        export LD=${_LD}
        export RANLIB=${_RANLIB}
        export STRIP=${_STRIP}
    fi

    cd build
    cmake .. -DUA_ENABLE_AMALGAMATION=ON -DCMAKE_BUILD_TYPE=Release # -DBUILD_SHARED_LIBS=ON
    make $MKTHD

    mkdir -p $tmp_open62541_output_path/lib
    cp -v open62541.c open62541.h $tmp_open62541_output_path
    cp bin/libopen62541.* $tmp_open62541_output_path/lib
EOF

}

make_open62541()
{
    set_open62541
    download_open62541_package
    tar_package

    if [ "$OPEN62541_FOR_HOST" = "yes" ];then
        mk_open62541 host
    fi
    if [ "$OPEN62541_FOR_TARGET" = "yes" ];then
        mk_open62541 target
    fi
}

