#!/bin/bash
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  2023-08-16 16:44:20 PM CST

##

source ../.common


export OPENER=OpEner
OUTPUT=${OUTPUT_PATH}/${OPENER}

using_release=0
# TO OLD TO USE
#OPENER_VERSION=2.2.1

function download_OpEner () {
    if [ $using_release -ne 0 ]; then
        # BUG : multiple definition of 'xx'
        # https://github.com/EIPStackGroup/OpENer/releases
        tget_and_rename https://github.com/EIPStackGroup/OpENer/archive/refs/tags/v${OPENER_VERSION}.tar.gz OpENer-${OPENER_VERSION}.tar.gz
        echo 'Do not use [github.com/EIPStackGroup/OpENer/releases], can not make it.'
        echo 'Following version is failed : v2.3, v2.2.1'
        echo "Tty use commit which data is after 2022.1"
        #rm OpENer-v*.t*
        sleep 3
    else
        tgit https://github.com/EIPStackGroup/OpENer
    fi
}

function mk_OpEner () {
    if [ $using_release -ne 0 ]; then
        OpEner_dir=${CODE_PATH}/OpENer-${OPENER_VERSION}
        echo "Tty use commit which data is after 2023.1"
        sleep 3
    else
        OpEner_dir=${CODE_PATH}/OpENer
    fi
    cd $OpEner_dir;

    LIBCAP_DIR_LIB=${LIBCAP_OUTPUT}/lib64
    LIBCAP_DIR_INC=${LIBCAP_OUTPUT}/include

    rm $LIBCAP_DIR_LIB/lib*.so* -rfv
    #rm $LIBCAP_DIR_LIB/lib*.a -rfv

read -r -d '' add_to_cmake_var <<- EOF
#添加动态连接库的路径
link_directories(${LIBCAP_OUTPUT}/lib64)
include_directories(${LIBCAP_OUTPUT}/include)
EOF


    check_when_add=`cat ${OpEner_dir}/source/CMakeLists.txt | head -n 10 | grep directories | grep libcap`
    if [ -z "$check_when_add" ]; then
        echo -e "${add_to_cmake_var}\n$(cat source/CMakeLists.txt)" > source/CMakeLists.txt
    fi

    ## 添加libcap目录
    # 生成编译脚本
(
    cat <<EOF
    echo 'Refer : bin/posix/setup_posix.sh'

    rm build -rf
    mkdir -p build


    cd build
    cmake -DCMAKE_C_COMPILER=${BUILD_HOST_}gcc -DOpENer_PLATFORM:STRING="POSIX" -DCMAKE_BUILD_TYPE:STRING="" -DBUILD_SHARED_LIBS:BOOL=OFF ../source
    make
EOF
) >   build.sh
    chmod +x build.sh
    ./build.sh
}


function make_OpEner ()
{
    #download_libcap
    cp ${BASE}/../libcap/compressed/libcap-${LIBCAP_VERSION}.tar.gz  $ARCHIVE_PATH -v

    download_OpEner  || return 1

    tar_package || return 1

    make_libcap
    mk_OpEner
}

make_OpEner
