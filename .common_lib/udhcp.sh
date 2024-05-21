
download_package_udhcp () {
    #下载包
    tget https://udhcp.busybox.net/source/udhcp-0.9.8.tar.gz
}

mk_udhcp () {
    cd ${BASE}/source/udhcp*
    sed -i '5, 12{s/COMBINED_BINARY=/#COMBINED_BINARY=/}' Makefile
    sed -i '130, 135{s/case INIT_SELECTING:/case INIT_SELECTING:;/}' dhcpc.c
    make   CROSS_COMPILE=${BUILD_HOST}-
}

do_copy_udhcp () {
    cd ${BASE}/source/udhcp*
    mkdir ${BASE}/install/udhcp -p
    mkdir ${BASE}/install/udhcp/sbin -p
    mkdir ${BASE}/install/udhcp/config -p


    cp ${BASE}/source/udhcp*/udhcpc  ${BASE}/install/udhcp/sbin -v
    cp ${BASE}/source/udhcp*/udhcpd  ${BASE}/install/udhcp/sbin -v
    # 默认的配置路径 /usr/share/udhcpc/default.script
    # 写进了代码中 dhcpc.c:62:#define DEFAULT_SCRIPT       "/usr/share/udhcpc/default.script"
    cp ${BASE}/source/udhcp*/samples/simple.script ${BASE}/install/udhcp/config/default.script -v
    cp ${BASE}/source/udhcp*/samples/udhcpd.conf ${BASE}/install/udhcp/config/ -v
}

make_udhcp ()
{
make_dirs
download_package_udhcp
tar_package
mk_udhcp
do_copy_udhcp
}
