# 老版本的libdrm，采用configure , make 的方式

export LIBDRM_LEAGCY=libdrm-2.4.89
LIBDRM_LEAGCY_DIR=${OUTPUT_PATH}/libdrm

download_libdrm_leagcy () {
    #https://dri.freedesktop.org/libdrm/
    tget https://dri.freedesktop.org/libdrm/${LIBDRM_LEAGCY}.tar.bz2
}

function mk_libdrm_leagcy () {
bash <<EOF

    cd ${CODE_PATH}/${LIBDRM_LEAGCY}

     ./configure \
    --host=${BUILD_HOST} \
    --prefix=${LIBDRM_LEAGCY_DIR} \
    --disable-nouveau \
    --enable-static \
    --enable-install-test-programs \
    --disable-cairo-tests
    #--with-plugindir=/usr/local/lib/alsa_lib

    make  $MKTHD
    make install
EOF
}

function make_libdrm_leagcy ()
{
    download_libdrm_leagcy || return 1
    tar_package || return 1
    mk_libdrm_leagcy || return 1
}

#cat <<EOF
#  --enable-udev           Enable support for using udev instead of mknod
#                          (default: disabled)
#  --disable-libkms        Disable KMS mm abstraction library (default: auto,
#                          enabled on supported platforms)
#  --disable-intel         Enable support for intel's KMS API (default: auto,
#                          enabled on x86)
#  --disable-radeon        Enable support for radeon's KMS API (default: auto)
#  --disable-amdgpu        Enable support for amdgpu's KMS API (default: auto)
#  --disable-nouveau       Enable support for nouveau's KMS API (default: auto)
#  --disable-vmwgfx        Enable support for vmwgfx's KMS API (default: yes)
#  --enable-omap-experimental-api
#                          Enable support for OMAP's experimental API (default:
#                          disabled)
#  --enable-exynos-experimental-api
#                          Enable support for EXYNOS's experimental API
#                          (default: disabled)
#  --disable-freedreno     Enable support for freedreno's KMS API (default:
#                          auto, enabled on arm)
#  --enable-freedreno-kgsl Enable support for freedreno's to use downstream
#                          android kernel API (default: disabled)
#  --enable-tegra-experimental-api
#                          Enable support for Tegra's experimental API
#                          (default: disabled)
#  --disable-vc4           Enable support for vc4's API (default: auto, enabled
#                          on arm)
#  --enable-etnaviv-experimental-api
#                          Enable support for etnaviv's experimental API
#                          (default: disabled)
#  --enable-install-test-programs
#                          Install test programs (default: no)
#  --enable-cairo-tests    Enable support for Cairo rendering in tests
#EOF
