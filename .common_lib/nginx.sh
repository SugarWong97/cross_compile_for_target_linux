PCRE=pcre-8.30
#NGINX=nginx-1.17.6
NGINX=nginx-1.25.4

NGINX_OUTOUT=${OUTPUT_PATH}/$NGINX

DEBUG_NGINX_CONFIG_CMD=${CODE_PATH}/${NGINX}/"configure.nginx"

set_nginx_info() {
    FIN_INSTALL_NGINX=/usr/${NGINX}
    ccinfo=${NGINX_OUTOUT}/nginx.info
}

download_nginx () {
    #下载包
    get_zlib
    get_ssl
    # 注意地址
    tget https://jaist.dl.sourceforge.net/project/pcre/pcre/8.30/${PCRE}.tar.bz2
    tget http://mirrors.sohu.com/nginx/${NGINX}.tar.gz
}

pre_configure_nginx () {
    cd ${CODE_PATH}/${NGINX}
    # auto/cc/name
    sed -r -i "/ngx_feature_run=yes/ s/.*/\tngx_feature_run=no/g" auto/cc/name
    sed -r -i "/exit 1/ s/.*//1" auto/cc/name

    # auto/types/sizeof
    sed -r -i "/ngx_size=`$NGX_AUTOTEST`/ s/.*/\tngx_size=4/g" auto/types/sizeof
    # auto/options
    sed -r -i "/PCRE_CONF_OPT=/ s/.*/PCRE_CONF_OPT=--host=arm/g" auto/options
}


configure_nginx () {
    cd ${CODE_PATH}/${NGINX}
    BUILD=`pwd`
    (
    cat <<EOF
    ./configure \
    --builddir=${BUILD} \
    --prefix=${NGINX_OUTOUT} \
    --with-http_mp4_module \
    --with-http_ssl_module \
    --without-http_upstream_zone_module \
    --with-openssl-opt=os/compiler:${_CC} \
    --with-cc=${_CC} \
    --with-cpp=${_CPP} \
    --with-ld-opt=-lpthread \
    --with-cc-opt='-D_FILE_OFFSET_BITS=64 -D__USE_FILE_OFFSET64' \
    --with-pcre=${CODE_PATH}/${PCRE} \
    --with-openssl=${CODE_PATH}/${OPENSSL} \
    --with-zlib=${CODE_PATH}/${ZLIB} \
    --with-http_v2_module
EOF
    ) > $DEBUG_NGINX_CONFIG_CMD
    bash $DEBUG_NGINX_CONFIG_CMD
}

pre_make_nginx () {
    cd ${CODE_PATH}/${NGINX}
    HEAD_FILE=`find . -name "ngx_auto_config.h"`
    DEL_LINE=`sed -n "/NGX_CONFIGURE/="  ${HEAD_FILE}`
    sed -i "${DEL_LINE}d" ${HEAD_FILE}
    (
    cat <<EOF
#undef NGX_CONFIGURE
#define NGX_CONFIGURE "./configure"
#ifndef NGX_SYS_NERR
#define NGX_SYS_NERR 132
#endif

#ifndef NGX_HAVE_SYSVSHM
#define NGX_HAVE_SYSVSHM 1
#endif
EOF
) >> ${HEAD_FILE}
    file_replace_match_lines ${HEAD_FILE} "#define NGX_PREFIX" "#define NGX_PREFIX \"${FIN_INSTALL_NGINX}/\""


    DEL_LINE=`sed -n "/modules\:/="  Makefile  | awk 'END {print}'`
    sed -i "${DEL_LINE}d" Makefile
    sed -i "${DEL_LINE}d" Makefile
    echo $?

    # 删除makefile 多余的几行
    DEL_LINE=`sed -n "/build\:/="  Makefile  | awk 'END {print}'`
    # 因为是有 2 行，删除以后文件会发生变化
    sed -i "${DEL_LINE}d" Makefile
    sed -i "${DEL_LINE}d" Makefile
    echo $?

    DEL_LINE=`sed -n "/install\:/="  Makefile  | awk 'END {print}'`
    sed -i "${DEL_LINE}d" Makefile
    sed -i "${DEL_LINE}d" Makefile
    echo $?

    return 0
}

mk_nginx () {
    set_nginx_info
    pre_configure_nginx
    configure_nginx
    pre_make_nginx

    cd ${CODE_PATH}/${NGINX}
    #export CC=gcc
    export CROSS_COMPILE=""
    file_replace_match_lines Makefile "install:" "install:"
    make $MKTHD build || return 1
    echo "OK"
    make install
    (
    cat <<EOF
${FIN_INSTALL_NGINX} for ${_CC}
-----------------

addgroup nogroup
adduser nobody

${FIN_INSTALL_NGINX}/sbin/nginx -c ${FIN_INSTALL_NGINX}/conf/nginx.conf
EOF
    ) > $ccinfo
}

make_nginx () {
    download_nginx
    tar_package
    mk_nginx
}

#sbin/nginx -c xx/nginx.conf
#
##  --sbin-path=PATH                   set nginx binary pathname
##  --modules-path=PATH                set modules path
#  --conf-path=PATH                   set nginx.conf pathname
#  --error-log-path=PATH              set error log pathname
#  --pid-path=PATH                    set nginx.pid pathname
#  --lock-path=PATH                   set nginx.lock pathname
#  --http-log-path=PATH               set http access log pathname
