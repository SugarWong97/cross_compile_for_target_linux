##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    2022年5月12日 16:58:31
##
#!/bin/bash

# 新版的libdrm开始采用meson + ninja 的方式编译了。

source ../.common
export LIBDRM=libdrm-2.4.110
LIBDRM_DIR=${OUTPUT_PATH}/libdrm

download_libdrm () {
    #https://dri.freedesktop.org/libdrm/
    tget https://dri.freedesktop.org/libdrm/${LIBDRM}.tar.xz
}

function make_libdrm () {
(
    cat <<EOF
[binaries]
c = '${_CC}'
cpp = '${_CPP}'
ar = '${_AR}'
strip = '${_STRIP}'

[host_machine]
system = 'linux'
cpu_family = 'arm'
cpu = 'armv7'
endian = 'little'

[build_machine]
system = 'linux'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'
EOF
) > ${CODE_PATH}/cross_file.txt
bash <<EOF
    cd ${CODE_PATH}/${LIBDRM}
    #创建编译目录
    mkdir build

    #进入build
    cd build
    #meson配置
    #-D 选定需要编译的模块
    # 选项的值可以是true、auto或者false
    meson --prefix=${LIBDRM_DIR} \
          --cross-file=${CODE_PATH}/cross_file.txt \
          -D amdgpu=false \
          -D cairo-tests=false \
          -D etnaviv=false \
          -D etnaviv=false \
          -D exynos=false \
          -D freedreno=false \
          -D freedreno-kgsl=false \
          -D install-test-programs=true \
          -D intel=false \
          -D libkms=false \
          -D man-pages=false \
          -D nouveau=false \
          -D omap=false \
          -D radeon=false \
          -D tegra=false \
          -D udev=false \
          -D valgrind=false \
          -D vc4=false \
          -D vmwgfx=false
    ninja && ninja install
EOF
}

function build_libdrm ()
{
    download_libdrm || return 1
    tar_package || return 1
    make_libdrm || return 1
}
require ninja
require meson
build_libdrm || echo "Err"

echo "=========================="
echo "Gen files in ${LIBDRM_DIR}"
