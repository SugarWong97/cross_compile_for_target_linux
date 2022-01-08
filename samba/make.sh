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
    cp ${BASE}/source/samba-${VERSION}/examples/smb.conf.default \
        ${OUTPUT_PATH}/samba-${VERSION}/smb.conf
    cp ${BASE}/source/samba-${VERSION}/examples/smb.conf.default \
        ${OUTPUT_PATH}/samba-${VERSION}/${FINDIR}/lib/smb.conf
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
}

## not support
build_samba4 () {
    return 1
}

#make_dirs
download_package
tar_package
build_samba3 || echo "Err"
