
source ../.common

LIBDRM_BUILD_WAY="leagcy"

if [ "$LIBDRM_BUILD_WAY" = "leagcy" ];then
    # 老版本的libdrm，采用configure , make 的方式
    make_libdrm_leagcy || echo "Err"
else
    # 新版的libdrm开始采用meson + ninja 的方式编译了。
    make_libdrm_meson_ninja || exit
    echo "=========================="
    echo "Gen files in ${LIBDRM_DIR}"
fi

