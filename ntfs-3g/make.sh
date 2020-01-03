##
#    Copyright By Schips, All Rights Reserved

BUILD_HOST=arm-linux
BASE=`pwd`
OUTPUT_PATH=${BASE}/install

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

tar_package () {
    cd ${BASE}/compressed
    ls * > /tmp/list.txt
    for TAR in `cat /tmp/list.txt`
    do
        tar -xf $TAR -C  ../source
    done
    rm -rf /tmp/list.txt
}
download_package () {
    cd ${BASE}/compressed
    tget https://tuxera.com/opensource/ntfs-3g_ntfsprogs-2017.3.23.tgz
}

make_ntfs3g () {
    cd ${BASE}/source/ntfs-3g*
    ./configure --host=${BUILD_HOST} \
    CC=${BUILD_HOST}-gcc   AR=${BUILD_HOST}-ar  \
    --prefix=${OUTPUT_PATH}/ntfs-3g/usr
    make 
    mkdir ${OUTPUT_PATH}/ntfs-3g -p
    mkdir ${OUTPUT_PATH}/ntfs-3g/sbin -p
    mkdir ${OUTPUT_PATH}/ntfs-3g/lib -p
    cp ${BASE}/source/ntfs-3g*/ntfsprogs/ntfsfix   ${OUTPUT_PATH}/ntfs-3g/sbin -v
    cp ${BASE}/source/ntfs-3g*/src/.libs/ntfs-3g   ${OUTPUT_PATH}/ntfs-3g/sbin -v

    cp ${BASE}/source/ntfs-3g*/libntfs-3g/.libs/libntfs-3g.so*  ${OUTPUT_PATH}/ntfs-3g/lib -v
}

make_dirs
download_package
tar_package
make_ntfs3g

echo <<EOF

得到： ntfs-3g（${OUTPUT_PATH}/bin） 以及 libntfs-3g.so.0.0.0 （${OUTPUT_PATH}/lib）
拷贝到对应的arm板目录中即可
EOF

#make install

# 参考 : https://www.cnblogs.com/schips/protected/p/11713617.html
