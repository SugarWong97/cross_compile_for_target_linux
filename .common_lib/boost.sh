export CONFIG_BOOST_VERSION=1.86.0
export BOOST_OUTPUT_PATH=${OUTPUT_PATH}/boost
export BOOST_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/boost

export BUILD_BOOST_FOR_HOST
export BUILD_BOOST_FOR_TARGET

set_boost()
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

download_boost_package () {
    local version_dot=`echo $CONFIG_BOOST_VERSION | sed 's/\./\_/g'`
    #### https://archives.boost.io/release/1.86.0/source/boost_1_86_0.tar.bz2
    tget https://archives.boost.io/release/${CONFIG_BOOST_VERSION}/source/boost_${version_dot}.tar.bz2
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
    set_boost
    download_boost_package
    tar_package
    mk_boost
}
