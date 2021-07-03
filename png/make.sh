##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make2.sh
#    Created  :  Tue 31 Mar 2020 10:09:09 AM CST

##
#!/bin/sh
source ../.common

download_package () {
    cd ${BASE}/compressed
    tget https://udomain.dl.sourceforge.net/project/libpng/libpng12/1.2.59/libpng-1.2.59.tar.gz
    get_zlib
}

function make_png () {
function _make_sh () {
cat<<EOF
	./configure --host=${BUILD_HOST} \
		--enable-shared \
		--enable-static \
		--prefix=${OUTPUT_PATH}/libpng \
		LDFLAGS="-L${OUTPUT_PATH}/${ZLIB}/lib" \
        CPPFLAGS="-I${OUTPUT_PATH}/${ZLIB}/include"
EOF
}
    # 编译安装 libpng
    cd ${BASE}/source/libpng*
    _make_sh > $tmp_config 
    source ./$tmp_config

    make clean
	make $MKTHD && make install
}

function make_build ()
{
    download_package  || return 1
    tar_package || return 1
    make_zlib  || return 1
    make_png  || return 1
}

make_build || echo "Err"
