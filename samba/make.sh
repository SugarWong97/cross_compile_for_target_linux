##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Sat 8 Jan 2022 07:17:28 AM CST

##
#!/bin/sh

source ../.common

## 在板子上需要配置的地址
FINDIR=/usr/local/samba
#BASE=`pwd`
#OUTPUT_PATH=${BASE}/install/
VERSION=3.5.4

download_package () {
    cd ${BASE}/compressed
    ## error
    #tget    https://download.samba.org/pub/samba/stable/samba-3.0.29.tar.gz
    #tget    https://download.samba.org/pub/samba/stable/samba-3.0.32.tar.gz
    #tget    https://download.samba.org/pub/samba/samba-3.0.37.tar.gz
    #tget    https://download.samba.org/pub/samba/stable/samba-3.6.25.tar.gz

    ## ok
    #tget    https://download.samba.org/pub/samba/samba-3.4.17.tar.gz
    tget    https://download.samba.org/pub/samba/stable/samba-3.5.4.tar.gz
}

# 3.0
build_samba3 () {
    (
cat <<EOF
#!/bin/bash
export PATH=$PATH

cd ${BASE}/source/samba-${VERSION}/source3

./configure  --build=i686 --host=${BUILD_HOST} \
    --prefix=${FINDIR} \
    --disable-cups --disable-iprint --enable-static=yes --disable-shared \
    samba_cv_CC_NEGATIVE_ENUM_VALUES=yes \
    2>&1 | tee ${BASE}/install/.configure.log

## 如果编译出错，试着关闭多线程编译（删除$MKTHD）
make $MKTHD && make DESTDIR=${OUTPUT_PATH}/samba-${VERSION} install $MKTHD
EOF
    ) > build.cmd
    bash build.cmd || return $?
    ## 新增安装帮助信息
(
    cat <<EOF
Let ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR} to '${FINDIR}'"
e.g.:
    (in host)
     cp ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR} <nfs-path>/`basename ${FINDIR}`

    (in board)
     mkdir -p `dirname ${FINDIR}`
     cp <nfs-path>/`basename ${FINDIR}` ${FINDIR}
EOF
)> ${OUTPUT_PATH}/samba-${VERSION}/install.path
    ## 减小文件大小
    find ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/bin -type f | grep -v smbpasswd | grep -v smbd | grep -v nmbd | xargs rm -vf {}
    find ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/sbin -type f | grep -v smbpasswd | grep -v smbd | grep -v nmbd | xargs rm -vf {}
    ${BUILD_HOST_}strip ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/sbin/*
    ${BUILD_HOST_}strip ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/bin/*
    ## 删除不必要的文件
    ### 头文件
    rm -rf ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/include
    ### man 文档
    rm -rf ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/share
    ### swat 服务有关文件
    rm -rf ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/swat
    rm -rf ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/lib/*
    ## 拷贝默认配置，并添加默认的配置
    cp ${BASE}/source/samba-${VERSION}/examples/smb.conf.default \
        ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/lib/smb.conf
#    ### 删掉home目录（当使用者登入samba server 后，samba 下会看到自己的家目录，目录名称是使用者自己的帐号）
#    local home_line_start=`cat ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/lib/smb.conf | grep -n -F "[homes]" | awk -F: '{print$1}'`
#    local home_line_end=$((${home_line_start}+3))
#    bash <<EOF
##!/bin/bash
#sed -i '$home_line_start,${home_line_end}d' ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/lib/smb.conf
#EOF

    ### 关闭打印机
    sed -r -i "/load printers/ s/.*/load printers=no/1" -i \
        ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/lib/smb.conf
    #sed -r -i "/printable/ s/.*/printable = no/1" -i  ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/lib/smb.conf
    ### 添加默认共享目录share，对应的路径为/tmp
    (
    cat <<EOF
[share]
comment = SMB Share

# change it as you want
path = /tmp

available = yes
browseable = yes

public = yes
writable = yes
EOF
    ) >> ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/lib/smb.conf
}

## not support
build_samba4 () {
    return 1
}

#make_dirs
download_package
tar_package
build_samba3 || echo "Err"
