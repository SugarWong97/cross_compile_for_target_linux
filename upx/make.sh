##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
##
#!/bin/sh

source ../.common

ULC=ucl-1.03
UPX=upx-3.96

ULC_INSTALL=${OUTPUT_PATH}/ucl
UXP_INSTALL=${OUTPUT_PATH}/upx

ALL_OTHERS=${OUTPUT_PATH}/.all_others

#下载包
download_upx () {
    get_zlib
    tget  http://www.oberhumer.com/opensource/ucl/download/ucl-1.03.tar.gz
    #tget https://github.com/upx/upx/archive/refs/tags/v3.00.tar.gz
    tget  https://github.com/upx/upx/releases/download/v3.96/upx-3.96-src.tar.xz
    #tget https://github.com/upx/upx/releases/download/v4.0.0/upx-4.0.0-arm_linux.tar.xz
}

function _file_replace_string(){
    local fin="$1"
    local old="$2"
    local new="$3"
    local oldt=`echo $old| sed 's:\/:\\\/:g'`
    local newt=`echo $new| sed 's:\/:\\\/:g'`
    if [ "${__replace_no_case_sensitivity}" = "no" ]; then
        bash <<EOF
sed 's/$oldt/$newt/g' -i $fin
EOF
        echo "Replace [$old] to [$new] in [$fin]."
    else
        bash <<EOF
sed 's/$oldt/$newt/gI' -i $fin
EOF
        echo "Replace [$old](ncs) to [$new] in [$fin]."
    fi
}


# 编译安装 ssl
make_ssl () {
    cd ${BASE}/source/${OPENSSL}
    echo "SSL ABOUT"
    CC=${_CC} ./config no-asm shared --prefix=${OUTPUT_PATH}/${OPENSSL}

    sed 's/-m64//g'  -i Makefile # 删除-m64 关键字 (arm-gcc 不支持)
    #sudo mv /usr/bin/pod2man /usr/bin/pod2man_bak
    #mv doc/apps /tmp/
    pre_make_ssl
    make $MKTHD && make install
}

## ssh 要求不能修改 prefix
do_copy () {
    cd ${BASE}/source/${OPENSSH}
    mkdir ${OUTPUT_PATH}/${OPENSSH}/bin -p
    mkdir ${OUTPUT_PATH}/${OPENSSH}/sbin -p
    mkdir ${OUTPUT_PATH}/${OPENSSH}/etc -p
    mkdir ${OUTPUT_PATH}/${OPENSSH}/libexec -p

    cp -v scp  sftp  ssh  ssh-add  ssh-agent \
        ssh-keygen  ssh-keyscan         ${OUTPUT_PATH}/${OPENSSH}/bin
    cp -v moduli ssh_config sshd_config ${OUTPUT_PATH}/${OPENSSH}/etc
    cp -v sftp-server  ssh-keysign      ${OUTPUT_PATH}/${OPENSSH}/libexec
    cp -v sshd                          ${OUTPUT_PATH}/${OPENSSH}/sbin

    #scp  sftp  ssh  ssh-add  ssh-agent  ssh-keygen  ssh-keyscan  拷贝到目标板/usr/local/bin
    #moduli ssh_config sshd_config拷贝到目标板 /usr/local/etc
    #sftp-server  ssh-keysign 拷贝到目标板 /usr/local/libexec
    #sshd 拷贝到目标板 /usr/local/sbin/
    echo "Copy all dirs under $FIN_INSTALL" > ${OUTPUT_PATH}/${OPENSSH}/install_path
}

make_ucl () {
    cd ${BASE}/source/$ULC

    ./configure --host=i386 --build=arm --prefix=${ULC_INSTALL} \
        --enable-static --disable-shared \
        --disable-asm \
        CC=${_CC} \
        AR=${_AR} \
        LD=${_LD} \
        RANLIB=${_RANLIB} \
        STRIP=${_STRIP} \
        CPPFLAGS="$CPPFLAGS -std=c90 -fPIC"
    make $MKTHD # 不能执行 install
    make install
}

make_upx_3 () {
    cd ${BASE}/source/upx* || return 1
    _file_replace_string src/Makefile "\$(UPX_UCLDIR)" "${ULC_INSTALL}"
    #export LD_LIBRARY_PATH=`pwd`:$LD_LIBRARY_PATH

    local UXP_DIR=`pwd`

    cp ${BASE}/meta/upx*/Makefile src
    export UPX_UCLDIR=${ALL_OTHERS}
    echo "export UPX_UCLDIR=${ALL_OTHERS}"
    #   CC=${_CC} \
    #   CXX=${_CXX} \
    #   AR=${_AR} \
    #   LD=${_LD} \
    #   RANLIB=${_RANLIB} \
    #   STRIP=${_STRIP} \
    make CROSS_COMPILE=${BUILD_HOST_} all || return 1
    mkdir ${UXP_INSTALL} -p
    cp -v $UXP_DIR/src/upx ${UXP_INSTALL}
    #make install
}

before_mk_uxp() {
    rm ${ALL_OTHERS} -rf
    mkdir -p ${ALL_OTHERS}

    rm ${OUTPUT_PATH}/*/lib/*.so*
    cp -rv ${OUTPUT_PATH}/*/lib/*      ${ALL_OTHERS}/
    cp -rv ${OUTPUT_PATH}/*/include/*  ${ALL_OTHERS}/
}

mk_upx ()
{
    make_dirs
    download_upx|| { echo >&2 "download_upx "; exit 1; }
    tar_package
    make_zlib || { echo >&2 "make_zlib "; exit 1; }
    make_ucl  || { echo >&2 "make_ucl ";  exit 1; }
    before_mk_uxp
    make_upx_3
}
mk_upx
