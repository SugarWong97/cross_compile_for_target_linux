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
download_upx4 () {
    tget https://github.com/upx/upx/releases/download/v4.0.0/upx-4.0.0-src.tar.xz
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

make_upx_4 () {
    cd ${BASE}/source/upx-4* || return 1
    #_file_replace_string src/Makefile "\$(UPX_UCLDIR)" "${ULC_INSTALL}"
    #export LD_LIBRARY_PATH=`pwd`:$LD_LIBRARY_PATH

    local UXP_DIR=`pwd`

    cp ${BASE}/meta/upx-4*/Makefile src
    export UPX_UCLDIR=${ALL_OTHERS}
    echo "export UPX_UCLDIR=${ALL_OTHERS}"
    #   CC=${_CC} \
    #   CXX=${_CXX} \
    #   AR=${_AR} \
    #   LD=${_LD} \
    #   RANLIB=${_RANLIB} \
    #   STRIP=${_STRIP} \
    make -C src CROSS_COMPILE=${BUILD_HOST_} || return 1
    mkdir ${UXP_INSTALL} -p
    cp -v $UXP_DIR/src/upx ${UXP_INSTALL}
    #make install
}

mk_upx4 ()
{
    make_dirs
    download_upx4|| { echo >&2 "download_upx "; exit 1; }
    tar_package
    make_upx_4
}
mk_upx4
