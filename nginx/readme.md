## 背景
Nginx 在一些基于web的嵌入式产品上能够使用，所以本人也介绍一下有关的支持。
> 本人的有关博客：《[Windows 编译安装 nginx 服务器 + rtmp 模块](https:////www.cnblogs.com/schips/p/12309174.html)》、《[Ubuntu 编译安装 nginx](https:////www.cnblogs.com/schips/p/12309201.html)》、《[Arm-Linux 移植 Nginx](https:////www.cnblogs.com/schips/p/12308651.html)》
> Host平台　　 ：Ubuntu 16.04
> Arm平台　　  ：3531d


[rcre](https://sourceforge.net/projects/pcre/files/pcre/8.30/)　　　　 ： [8.30](https://jaist.dl.sourceforge.net/project/pcre/pcre/8.30/pcre-8.30.tar.bz2)

[zlib](https://www.zlib.net/)　　　　   ：[1.2.11](https://www.zlib.net/zlib-1.2.11.tar.gz)

[openssl](https://www.openssl.org/source/)　　  ： [1.0.2t](https://www.openssl.org/source/openssl-1.0.2t.tar.gz)

[nginx](http://mirrors.sohu.com/nginx/)　　　   ： [1.17.6 （本文完全适用于 1.15版本的 nginx）](http://mirrors.sohu.com/nginx/nginx-1.17.6.tar.gz)

 

arm-gcc　　 ：4.9.4

注意：
- 这个和以往的交叉编译不一样，nginx的交叉编译依赖的库都是源码包，而不是最终的结果。
- 由于nginx在嵌入式下的支持不是很好，所以在配置编译之前，需要手动修改工程中的某些项目。


## 主机准备

```bash
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

}

tget () { #try wget
    filename=`basename $1`
    echo "Downloading [${filename}]..."
    if [ ! -f ${filename} ];then
        wget $1
    fi

    echo "[OK] Downloaded [${filename}] "
}

download_package () {
    cd ${BASE}/compressed
    #下载包
    tget https://www.zlib.net/${ZLIB}.tar.gz
    tget https://www.openssl.org/source/${OPENSSL}.tar.gz
    # 注意地址
    tget https://jaist.dl.sourceforge.net/project/pcre/pcre/8.30/${PCRE}.tar.bz2
    tget http://mirrors.sohu.com/nginx/${NGINX}.tar.gz
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
}
sudo ls
make_dirs
#download_package
tar_package
pre_configure_nginx
configure_nginx
pre_make_nginx
make_nginx
```

这样应该就没有什么问题了。

 
## arm板子准备

整个目录 拷贝 到板子，具体以prefix指定的路径为准上

添加nginx有关库和运行路径环境变量

完成nginx.conf的配置…(此步骤省略) 

```
/usr/nginx/sbin/nginx -c /usr/nginx/conf/nginx.conf -p usr/nginx #启动nginx
```

 

![这里写图片描述](https://img-blog.csdn.net/20170323200027573?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbHpfb2Jq/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

 

## 编译nginx时指定外部模块

第三方模块下载地址：https://www.nginx.com/resources/wiki/modules/index.html

使第三方模块的生效方法： ./configure  --add-module=模块的路径

例如：

```
/configure --prefix=/usr/local/nginx-1.4.1 \  
 --with-http_stub_status_module \  
 --with-http_ssl_module --with-http_realip_module \  
 --with-http_image_filter_module \  
 --add-module=../ngx_pagespeed-master  
```

 

 

**正文到此结束，但为了让读者能够搞清楚脚本中的非常规指令的意义，本人保留了下文，以作为手动修改的参考依据。**



nginx根目录下， 执行此脚本，再一步步排查错误。

```
    cd ${BASE}/source/${NGINX}
    echo ${BASE}/source/${NGINX}
    BUILD=`pwd`
    ./configure \
    --builddir=${BUILD} \
    --prefix=${BASE}/install/nginx \
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
    --with-http_v2_module
```



提示



```
checking for OS
 + Linux 4.15.0-65-generic x86_64
checking for C compiler ... found but is not working

./configure: error: C compiler arm-hisiv500-linux-gcc is not found

make: *** No rule to make target 'build', needed by 'default'.  Stop.
```

![img](https://img2018.cnblogs.com/blog/1281523/201910/1281523-20191028093908989-404404915.png)



 

 解决方法：



```
 修改 auto/cc/name

 　　ngx_feature_run=yes 👉 ngx_feature_run=no

　　 exit 1 👉 删掉或者注释
```

![img](https://img2018.cnblogs.com/blog/1281523/201910/1281523-20191028094059112-1058483129.png)



再次运行

```
./configure: error: can not detect int size
```

![img](https://img2018.cnblogs.com/blog/1281523/201910/1281523-20191028094644524-1795449831.png)

 解决方法：



```
 vi auto/types/sizeof
 ngx_test中的 $CC 👉 gcc
 ngx_size=`$NGX_AUTOTEST` 👉  ngx_size=4
```

![img](https://img2018.cnblogs.com/blog/1281523/201910/1281523-20191028094922693-2076833319.png)



 

 

 

 

配置通过以后，  就可以开始make



```
checking whether we are cross compiling... configure: error: in `nginx-1.15.2/pcre-8.30':
configure: error: cannot run C compiled programs.
If you meant to cross compile, use `--host'.
See `config.log' for more details
Makefile:1282: recipe for target 'pcre-8.30/Makefile' failed
make: *** [pcre-8.30/Makefile] Error 1
```



解决方法



```
vi auto/options
 根据情况改成自己的交叉编译工具链
PCRE_CONF_OPT= 👉 PCRE_CONF_OPT=-–host=arm-hisiv600-linux
```

![img](https://img2018.cnblogs.com/blog/1281523/201910/1281523-20191028095730121-1303579739.png)



 

 **修改以后重新运行 ./make.sh以后再 make**



```
src/os/unix/ngx_errno.c: In function ‘ngx_strerror’:
src/os/unix/ngx_errno.c:37:31: error: ‘NGX_SYS_NERR’ undeclared (first use in this function)
     msg = ((ngx_uint_t) err < NGX_SYS_NERR) ? &ngx_sys_errlist[err]:
                               ^
src/os/unix/ngx_errno.c:37:31: note: each undeclared identifier is reported only once for each function it appears in
src/os/unix/ngx_errno.c: In function ‘ngx_strerror_init’:
src/os/unix/ngx_errno.c:58:11: error: ‘NGX_SYS_NERR’ undeclared (first use in this function)
     len = NGX_SYS_NERR * sizeof(ngx_str_t);
           ^
Makefile:693: recipe for target '/home/schips/arm/nginx/source/nginx-1.15.2/src/os/unix/ngx_errno.o' failed
make: *** [/home/linkpi/arm/nginx/source/nginx-1.15.2/src/os/unix/ngx_errno.o] Error 1
```



```
解决方法： 
```



```
    添加以下3行到 ngx_auto_config.h 中 （根据有关的源码可知， 这个宏和操作系统识别的错误个数有关）
　　# ngx_auto_config.h 文件的位置和 $OBJ 变量有关
　　

　　　　#ifndef NGX_SYS_NERR
　　　　#define NGX_SYS_NERR 132
　　　　#endif

　　// 注意： NGX_SYS_NERR不是在src里面的，而是编译的时候根据操作系统的不同而生成的不内容
　　// 为了稳定，我们参考host端的结果，使用132作为值。
```



 

继续make



```
nginx-1.15.2/src/core/ngx_cycle.o: In function `ngx_init_cycle':
nginx-1.15.2/src/core/ngx_cycle.c:476: undefined reference to `ngx_shm_alloc'
nginx-1.15.2/src/core/ngx_cycle.c:685: undefined reference to `ngx_shm_free'
nginx-1.15.2/src/event/ngx_event.o: In function `ngx_event_module_init':
nginx-1.15.2/src/event/ngx_event.c:546: undefined reference to `ngx_shm_alloc'
collect2: error: ld returned 1 exit status
Makefile:247: recipe for target 'nginx-1.15.2/nginx' failed
make: *** [nginx-1.15.2/nginx] Error 1
```



解决方法：



```
由于，ngx_shm_free ngx_shm_alloc 这几个函数被条件宏NGX_HAVE_MAP_ANON，NGX_HAVE_SYSVSHM NGX_HAVE_MAP_DEVZERO，
3者选1，而nginx 的交叉编译不够友好，所以需要我们手动添加。

找到 ngx_auto_config.h  

添加以下3行

#ifndef NGX_HAVE_SYSVSHM
#define NGX_HAVE_SYSVSHM 1
#endif
```



 

make出现死循环（每次配置以后都需要执行）



```
nginx-1.15.2/Makefile:1374: recipe for target 'build' failed
make[650]: *** [build] Interrupt
nginx-1.15.2/Makefile:1374: recipe for target 'build' failed
make[649]: *** [build] Interrupt
nginx-1.15.2/Makefile:1374: recipe for target 'build' failed
make[648]: *** [build] Interrupt
nginx-1.15.2/Makefile:1374: recipe for target 'build' failed
make[647]: *** [build] Interrupt
nginx-1.15.2/Makefile:1374: recipe for target 'build' failed
make[646]: *** [build] Interrupt
```



 解决方法：



```
删除nginx根目录图中这几行（位于1377行左右）

   7 build:
   6     $(MAKE) -f /home/schips/arm/nginx/source/nginx-1.15.2/Makefile
   5
   4 install:
   3     $(MAKE) -f /home/schips/arm/nginx/source/nginx-1.15.2/Makefile install
   2
   1 modules:
1380     $(MAKE) -f /home/schips/arm/nginx/source/nginx-1.15.2/Makefile modules
```



 

**再次编译：**

由于每次配置（configure）会使ngx_auto_config.h重置。为了方便维护，我们将有关的改动做成脚本。



```
##
#    Copyright By Schips, All Rights Reserved
BUILD=.
./configure \
--builddir=${BUILD} \
--prefix='/home/schips/arm/nginx/install/nginx' \
--with-http_mp4_module \
--with-http_ssl_module \
--without-http_upstream_zone_module \
--with-pcre=./pcre-8.30 \
--with-openssl=./openssl-1.0.2t \
--with-zlib=./zlib-1.2.11 \
--with-cc=arm-hisiv500-linux-gcc \
--with-cpp=arm-hisiv500-linux-g++ \
--with-ld-opt=-lpthread \
--with-cc-opt='-D_FILE_OFFSET_BITS=64 -D__USE_FILE_OFFSET64' \
--with-openssl-opt=os/compiler:arm-hisiv500-linux-gcc \
--with-http_v2_module || exit 1


echo "// schips add"               >> ngx_auto_config.h
echo "#ifndef NGX_SYS_NERR"        >> ngx_auto_config.h
echo "#define NGX_SYS_NERR 132"    >> ngx_auto_config.h
echo "#endif"                      >> ngx_auto_config.h
echo ""                            >> ngx_auto_config.h
echo "#ifndef NGX_HAVE_SYSVSHM"    >> ngx_auto_config.h
echo "#define NGX_HAVE_SYSVSHM 1"  >> ngx_auto_config.h
echo "#endif"                      >> ngx_auto_config.h
echo "Need edit Makefile" && exit 1
make CC=arm-hisiv500-linux-gcc
make install
```



 

**使用已经编译好的 openssl库以加快编译速度（在本文中未启用）**
--with-openssl 参数虽然可以指定 OpenSSL 路径，但只支持 OpenSSL 的源代码，不支持已编译好的 OpenSSL。

每回更新 nginx 都要重新编译 OpenSSL 肯定很麻烦，网上找到一个方案，觉得很好，记录下来。



```
1.1 首先使用交叉编译Openssl:

CC=arm-linux-gnueabi-gcc ./config no-asm shared --prefix=/app/my_lib

1.2 修改nginx的Mkaefile代码：

把
 31#CORE_INCS="$CORE_INCS $OPENSSL/.openssl/include"
 32#CORE_DEPS="$CORE_DEPS $OPENSSL/.openssl/include/openssl/ssl.h"
 33#CORE_LIBS="$CORE_LIBS $OPENSSL/.openssl/lib/libssl.a"
 34#CORE_LIBS="$CORE_LIBS $OPENSSL/.openssl/lib/libcrypto.a"
 35#CORE_LIBS="$CORE_LIBS $NGX_LIBDL"
 改为：
 37CORE_INCS="$CORE_INCS $OPENSSL/include"
 38CORE_DEPS="$CORE_DEPS $OPENSSL/include/openssl/ssl.h"
 39CORE_LIBS="$CORE_LIBS $OPENSSL/libssl.a"
 40CORE_LIBS="$CORE_LIBS $OPENSSL/libcrypto.a"
 41CORE_LIBS="$CORE_LIBS $NGX_LIBDL"
 41CORE_LIBS="$CORE_LIBS $NGX_LIBDL"
```



 
