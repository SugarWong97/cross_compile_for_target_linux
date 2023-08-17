NTFS3G_VERSION=2017.3.23
download_ntfs3g () {
    tget https://tuxera.com/opensource/ntfs-3g_ntfsprogs-${NTFS3G_VERSION}.tgz
}

mk_ntfs3g () {
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

make_ntfs3g () {
    make_dirs
    download_ntfs3g
    tar_package
    mk_ntfs3g
}

echo <<EOF

得到： ntfs-3g（${OUTPUT_PATH}/bin） 以及 libntfs-3g.so.0.0.0 （${OUTPUT_PATH}/lib）
拷贝到对应的arm板目录中即可
EOF

#make install

# 参考 : https://www.cnblogs.com/schips/protected/p/11713617.html
