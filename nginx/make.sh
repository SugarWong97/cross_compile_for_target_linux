##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Fri 22 Nov 2019 11:49:30 AM CST

##
#!/bin/sh
BASE=`pwd`
BUILD_HOST=arm-linux
ZLIB=zlib-1.2.11
OPENSSL=openssl-1.0.2t
PCRE=pcre-8.30
NGINX=nginx-1.17.6
FIN_INSTALL=/usr/${NGINX}

make_dirs() {
    cd ${BASE}
    mkdir  compressed  install  source -p
    rm source/* -rf
}

download_package () {
    cd ${BASE}/compressed
    #下载包
    wget -c https://www.zlib.net/${ZLIB}.tar.gz
    wget    https://www.openssl.org/source/${OPENSSL}.tar.gz
    # 注意地址
    wget -c https://jaist.dl.sourceforge.net/project/pcre/pcre/8.30/${PCRE}.tar.bz2
    wget -c http://mirrors.sohu.com/nginx/${NGINX}.tar.gz
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

pre_configure_nginx () {
    cd ${BASE}/source/${NGINX}
    # auto/cc/name
    sed -r -i "/ngx_feature_run=yes/ s/.*/\tngx_feature_run=no/g" auto/cc/name
    sed -r -i "/exit 1/ s/.*//1" auto/cc/name

    # auto/types/sizeof
    sed -r -i "/ngx_size=`$NGX_AUTOTEST`/ s/.*/\tngx_size=4/g" auto/types/sizeof
    # 
    sed -r -i "/PCRE_CONF_OPT=/ s/.*/PCRE_CONF_OPT=--host=${BUILD_HOST}/g" auto/options
}

 
configure_nginx () {
    cd ${BASE}/source/${NGINX}
    BUILD=`pwd`
    ./configure \
    --builddir=${BUILD} \
    --prefix=${FIN_INSTALL} \
    --with-http_mp4_module \
    --with-http_ssl_module \
    --without-http_upstream_zone_module \
    --with-openssl-opt=os/compiler:${BUILD_HOST}-gcc \
    --with-cc=${BUILD_HOST}-gcc \
    --with-cpp=${BUILD_HOST}-g++ \
    --with-ld-opt=-lpthread \
    --with-cc-opt='-D_FILE_OFFSET_BITS=64 -D__USE_FILE_OFFSET64' \
    --with-pcre=${BASE}/source/${PCRE} \
    --with-openssl=${BASE}/source/${OPENSSL} \
    --with-zlib=${BASE}/source/${ZLIB} \
    --with-http_v2_module && echo "${FIN_INSTALL} with ${BUILD_HOST}" > ccinfo
}

pre_make_nginx () {
    cd ${BASE}/source/${NGINX}
    HEAD_FILE=`find . -name "ngx_auto_config.h"`
    DEL_LINE=`sed -n "/NGX_CONFIGURE/="  ${HEAD_FILE}`
	sed -i "${DEL_LINE}d" ${HEAD_FILE}
    echo "#undef NGX_CONFIGURE " >> ${HEAD_FILE}
    echo "#define NGX_CONFIGURE \"./configure\"" >> ${HEAD_FILE}
    echo "#ifndef NGX_SYS_NERR" >> ${HEAD_FILE}
    echo "#define NGX_SYS_NERR 132" >> ${HEAD_FILE}
    echo "#endif" >> ${HEAD_FILE}
    
    echo "#ifndef NGX_HAVE_SYSVSHM" >> ${HEAD_FILE}
    echo "#define NGX_HAVE_SYSVSHM 1" >> ${HEAD_FILE}
    echo "#endif" >> ${HEAD_FILE}

    # 删除makefile 多余的几行

	DEL_LINE=`sed -n "/build\:/="  Makefile  | awk 'END {print}'`
    # 因为是有 2 行，删除以后文件会发生变化
	sed -i "${DEL_LINE}d" Makefile
	sed -i "${DEL_LINE}d" Makefile

	DEL_LINE=`sed -n "/install\:/="  Makefile  | awk 'END {print}'`
	sed -i "${DEL_LINE}d" Makefile
	sed -i "${DEL_LINE}d" Makefile

	DEL_LINE=`sed -n "/modules\:/="  Makefile  | awk 'END {print}'`
	sed -i "${DEL_LINE}d" Makefile
	sed -i "${DEL_LINE}d" Makefile

}

make_nginx () {
    cd ${BASE}/source/${NGINX}
    make -j4 && sudo make install && sudo mv ccinfo ${FIN_INSTALL}/ccinfo
    sudo mv ${FIN_INSTALL} ${BASE}/install
}

 echo "Using ${BUILD_HOST}-gcc"
make_dirs
sudo ls
#download_package
tar_package
pre_configure_nginx
configure_nginx
pre_make_nginx
make_nginx

exit $?

sbin/nginx -c xx/nginx.conf

#  --sbin-path=PATH                   set nginx binary pathname
#  --modules-path=PATH                set modules path
  --conf-path=PATH                   set nginx.conf pathname
  --error-log-path=PATH              set error log pathname
  --pid-path=PATH                    set nginx.pid pathname
  --lock-path=PATH                   set nginx.lock pathname
  --http-log-path=PATH               set http access log pathname
