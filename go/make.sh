##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Tue 25 Feb 2020 03:05:11 PM CST

##
#!/bin/sh
source ../.common

ARM_GO_DIR=${CODE_PATH}/_arm_go
HIG_GO_DIR=${CODE_PATH}/_go_higher
BOOTSTRAP_DIR=${CODE_PATH}/_go_boot_strap

export GOROOT_BOOTSTRAP=${BOOTSTRAP_DIR}/go

export GCC_FULL_PATH=`whereis ${_CC} | awk -F: '{ print $2 }' | awk '{print $1}'` # 防止多个结果
export GCC_DIR=`dirname ${GCC_FULL_PATH}/`
CROSS_TOOL_DIR=${GCC_DIR}

download_package () {
    cd ${BASE}/compressed
    # bootstap
    tget https://dl.google.com/go/go1.4.3.src.tar.gz
    # 高版本
    tget https://dl.google.com/go/go1.13.8.src.tar.gz
}

tar_go_for_boot_stap () {
    cd ${BASE}/compressed

    mkdir ${BOOTSTRAP_DIR} -p
    tar -xf *go1.4* -C ${BOOTSTRAP_DIR}
}

make_go_for_boot_stap () {
    cd ${BOOTSTRAP_DIR}/go/src

    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 ./make.bash
}

function make_go_version_higher_host() {
function tar_go_version_higher_host () {
    cd ${BASE}/compressed
    HIGHER=`ls go* | grep -v 1.4 `

    mkdir ${HIG_GO_DIR} -p
    tar -xf $HIGHER -C ${HIG_GO_DIR}
}
    # tar_go_version_higher_host  || return 1
    cd ${HIG_GO_DIR}/go/src
    GOOS=linux GOARCH=amd64 ./make.bash
}

tar_go_version_higher_arm () {
    cd ${BASE}/compressed
    HIGHER=`ls go* |grep -v 1.4 `
    mkdir ${ARM_GO_DIR} -p
    tar -xvf $HIGHER -C ${ARM_GO_DIR}
}

make_go_version_higher_arm() {

    cd ${ARM_GO_DIR}/go/src
    CGO="no"
    if [ $CGO = "yes" ]
    then
        echo "CGO is enable"
        # 开启CGO编译（参考下文）
        export  CC_FOR_TARGET=${CROSS_TOOL_DIR}/${_CC}
        export CXX_FOR_TARGET=${CROSS_TOOL_DIR}/${_CPP}
        CGO_ENABLED=1 GOOS=linux GOARCH=arm GOARM=7 ./make.bash
    else
        echo "CGO is disable"
        # 关闭CGO编译
        CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=7 ./make.bash
    fi
}

reorganize () {
    #boot strap
    mv ${BOOTSTRAP_DIR}/go ${OUTPUT_PATH}/go_boot_strap

    #higher_host(好像arm版本的编译里面也自带了本机可以用的go)
    #mv ${HIG_GO_DIR}/go  ${BASE}/install/go_host

    #higher_arm
    mv ${ARM_GO_DIR}/go ${OUTPUT_PATH}/go_arm

    echo "go bootstarp  is  : $GOROOT_BOOTSTRAP"
    echo "CC_FOR_TARGET  is : ${CROSS_TOOL_DIR}/${BUILD_HOST}-gcc"
    echo "CXX_FOR_TARGET is : ${CROSS_TOOL_DIR}/${BUILD_HOST}-g++"

    # 关于下方的变量请参考有关文章
    GOROOT="${OUTPUT_PATH}/go_host"
    GOPATH=`dirname $GOROOT`/gopath
    echo "GOROOT is : ${GOROOT}"
    echo "GOPATH is : ${GOPATH}"

}

function make_build ()
{
    download_package  || return 1
    tar_go_for_boot_stap  || return 1
    make_go_for_boot_stap  || return 1
        #arm版本的编译里面也带了本机可以用的go，
        #make_go_version_higher_host  || return 1

    tar_go_version_higher_arm  || return 1
    make_go_version_higher_arm  || return 1

    reorganize  || return 1
}

make_build || echo "Err"
exit $?
#################### 如何配置go
