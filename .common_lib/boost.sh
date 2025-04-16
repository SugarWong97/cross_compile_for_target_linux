BOOST=boost
export CONFIG_BOOST_VERSION=1.86.0
export BOOST_VERSION=${BOOST}_${CONFIG_BOOST_VERSION}

export BOOST_OUTPUT_PATH=${OUTPUT_PATH}/boost
export BOOST_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/boost

## for others
export BOOST_FILE_NAME=`echo ${BOOST_VERSION} | sed 's/\./\_/g'`.tar.bz2
export BOOST_ARCH_PATH=$ROOT_DIR/boost/compressed/${BOOST_FILE_NAME}

export BUILD_BOOST_FOR_HOST
export BUILD_BOOST_FOR_TARGET

set_build_boost()
{
    if [ "$BUILD_BOOST_FOR_HOST" = "n" ];then
        export BOOST_FOR_HOST="no"
    else
        export BOOST_FOR_HOST="yes"
    fi

    if [ "$BUILD_BOOST_FOR_TARGET" = "n" ];then
        export BOOST_FOR_TARGET="no"
    else
        export BOOST_FOR_TARGET="yes"
    fi
}

function _sync_export_var_boost()
{
    export BOOST_VERSION=${BOOST}_${CONFIG_BOOST_VERSION}
    export BOOST_FILE_NAME=`echo ${BOOST_VERSION} | sed 's/\./\_/g'`.tar.bz2
    export BOOST_ARCH_PATH=$ROOT_DIR/boost/compressed/${BOOST_FILE_NAME}
}

get_boost () {
    _sync_export_var_boost
    tget_package_from_arch $BOOST_ARCH_PATH  $ARCHIVE_PATH/$BOOST_FILE_NAME https://archives.boost.io/release/${CONFIG_BOOST_VERSION}/source/$BOOST_FILE_NAME
}

mk_boost()
{
    local version_dot=`echo $CONFIG_BOOST_VERSION | sed 's/\./\_/g'`
    cd ${CODE_PATH}/boost*${version_dot}*

    echo "Buding Bootstrap" && sleep 1
    if [ ! -f b2 ]; then
        ./bootstrap.sh || return 1
    fi

    if [ "$BOOST_FOR_HOST" = "yes" ];then
        echo "Buding Host" && sleep 1
        file_replace_match_lines project-config.jam "using gcc" "using gcc ;"
        ./b2 install --prefix=${BOOST_OUTPUT_PATH_HOST} --build-dir="build/x86"
    fi

    if [ "$BOOST_FOR_TARGET" = "yes" ];then
        echo "Buding Target" && sleep 1
        file_replace_match_lines project-config.jam "using gcc" "using gcc : : $BUILD_HOST_FULL_PATH ;"
        ./b2 install --prefix=${BOOST_OUTPUT_PATH} --build-dir="build/target"
    fi
}

make_boost()
{
    _sync_export_var_boost
    set_build_boost
    get_boost
    tar_package
    mk_boost
}
