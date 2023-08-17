# 新版的libdrm开始采用meson + ninja 的方式编译了。
export LIBDRM=libdrm-2.4.110
export LIBDRM_DIR=${OUTPUT_PATH}/libdrm

download_libdrm_meson_ninja () {
    #https://dri.freedesktop.org/libdrm/
    tget https://dri.freedesktop.org/libdrm/${LIBDRM}.tar.xz
}

function mk_libdrm_meson_ninja () {
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
    require ninja
    require meson
    download_libdrm_meson_ninja || return 1
    tar_package || return 1
    mk_libdrm_meson_ninja || return 1
}

