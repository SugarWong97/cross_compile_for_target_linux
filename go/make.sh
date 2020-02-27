##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Tue 25 Feb 2020 03:05:11 PM CST

##
#!/bin/sh
# 注意 go 的脚本不具备通用性
BUILD_HOST=arm-linux
BASE=`pwd`

ARM_GO_DIR=${BASE}/source/_arm_go
HIG_GO_DIR=${BASE}/source/_go_higher
BOOTSTRAP_DIR=${BASE}/source/_go_boot_strap

GOROOT_BOOTSTRAP=${BOOTSTRAP_DIR}/go


CROSS_TOOL_DIR=`dirname \`whereis ${BUILD_HOST}-gcc | awk -F: '{ print $2 }'\``

make_dirs () {
    #为了方便管理，创建有关的目录
    cd ${BASE} && mkdir compressed install source -p
}

tget () { #try wget
    filename=`basename $1`
    echo "Downloading [${filename}]..."
    if [ ! -f ${filename} ];then
        wget $1
    fi

    echo "[OK] Downloaded [${filename}] "
}

download_package () {
    cd ${BASE}/compressed

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

tar_go_version_higher_host () {
    cd ${BASE}/compressed
    HIGHER=`ls go* | grep -v 1.4 `

    mkdir ${HIG_GO_DIR} -p
    tar -xf $HIGHER -C ${HIG_GO_DIR}
}

make_go_version_higher_host() {
    export GOROOT_BOOTSTRAP=$GOROOT_BOOTSTRAP

    cd ${HIG_GO_DIR}/go/src
    GOOS=linux GOARCH=amd64 ./make.bash
}

tar_go_version_higher_arm () {
    cd ${BASE}/compressed
    HIGHER=`ls go* |grep -v 1.4 `
    mkdir ${ARM_GO_DIR} -p
    tar -xf $HIGHER -C ${ARM_GO_DIR}
}

make_go_version_higher_arm() {
    export GOROOT_BOOTSTRAP=$GOROOT_BOOTSTRAP

    cd ${ARM_GO_DIR}/go/src
    CGO="no"
    if [ $CGO = "yes" ]
    then
        echo "CGO is enable"
        # 开启CGO编译（参考下文）
        export  CC_FOR_TARGET=${CROSS_TOOL_DIR}/${BUILD_HOST}-gcc
        export CXX_FOR_TARGET=${CROSS_TOOL_DIR}/${BUILD_HOST}-g++
        CGO_ENABLED=1 GOOS=linux GOARCH=arm GOARM=7 ./make.bash
    else
        echo "CGO is disable"
        # 关闭CGO编译
        CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=7 ./make.bash
    fi

}

make_together () {
    #boot strap
    mv ${BOOTSTRAP_DIR}/go ${BASE}/install/go_boot_strap

    #higher_host(好像arm版本的编译里面也自带了本机可以用的go)
    #mv ${HIG_GO_DIR}/go  ${BASE}/install/go_host

    #higher_arm
    mv ${ARM_GO_DIR}/go ${BASE}/install/go_arm

    echo "go bootstarp  is  : $GOROOT_BOOTSTRAP"
    echo "CC_FOR_TARGET  is : ${CROSS_TOOL_DIR}/${BUILD_HOST}-gcc"
    echo "CXX_FOR_TARGET is : ${CROSS_TOOL_DIR}/${BUILD_HOST}-g++"

    # 关于下方的变量请参考有关文章
    GOROOT="${BASE}/install/go_host"
    GOPATH=`dirname $GOROOT`/gopath
    echo "GOROOT is : ${GOROOT}"
    echo "GOPATH is : ${GOPATH}"

}


echo "Using ${BUILD_HOST}-gcc"
make_dirs
download_package

  tar_go_for_boot_stap
 make_go_for_boot_stap

#好像arm版本的编译里面也带了本机可以用的go，
# tar_go_version_higher_host
#make_go_version_higher_host

 tar_go_version_higher_arm
 make_go_version_higher_arm

make_together
