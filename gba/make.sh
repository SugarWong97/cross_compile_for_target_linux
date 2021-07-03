##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
#    Created  :  Sat 30 Nov 2019 01:56:37 PM CST
##
#!/bin/sh
source ../.common

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

function make_sdl () {
function _make_sh () {
cat<<EOF
    ./configure --disable-pulseaudio \
		--prefix=${OUTPUT_PATH}/SDL \
		--host=${BUILD_HOST} \
		--disable-video-nanox \
		-disable-video-qtopia \
		--disable-static \
		--enable-shared \
		--disable-video-photon \
		--disable-video-ggi \
		--disable-video-svga \
		--disable-video-aalib \
		--disable-video-dummy \
		--disable-video-dga \
		--disable-arts \
		--disable-esd \
		--disable-alsa \
		--disable-video-x11 \
		--disable-nasm \
		--disable-input-tslib \
		-enable-video-fbcon 
EOF
}
    cd ${BASE}/source/S*
    _make_sh > $tmp_config 
    source ./$tmp_config
    make clean
    make $MKTHD && make install

}

function make_vba () {
function _make_sh () {
cat<<EOF
    ./configure --host=${BUILD_HOST} \
        --target=${BUILD_HOST} \
        --with-sdl-prefix=${OUTPUT_PATH}/SDL \
        --with-sdl-exec-prefix=${OUTPUT_PATH}/SDL \
        --enable-shared \
        --enable-static \
        --prefix=${OUTPUT_PATH}/vba \
        LDFLAGS="-L${OUTPUT_PATH}/${ZLIB}/lib -L${OUTPUT_PATH}/libpng/lib" \
        CPPFLAGS="-fpermissive -I${OUTPUT_PATH}/${ZLIB}/include -I${OUTPUT_PATH}/libpng/include"
EOF
}
    # 编译安装 libpng
    cd ${BASE}/source/V*
    _make_sh > $tmp_config 
    source ./$tmp_config
    make clean
    cp ${BASE}/debugger.cpp ${BASE}/source/VisualBoyAdvance-1.7.2/src/sdl/debugger.cpp
    make $MKTHD && make install
}

function make_build ()
{
    tar_package || return 1
    make_zlib || return 1
    make_png || return 1
    make_sdl || return 1
    make_vba || return 1
}

make_build || echo "Err"
