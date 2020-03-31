

## 背景

[libcurl]( http://curl.haxx.se/)是一个跨平台的开源网络协议库，支持http, https, rtsp等多种协议 。libcurl同样支持HTTPS证书授权，HTTP POST, HTTP PUT, FTP 上传, HTTP基本表单上传，代理，cookies和用户认证。

> host平台　　 ：Ubuntu 16.04
> arm平台　　 ： 3531d
> arm-gcc　　 ：4.9.4
>
> [libcrul](https://curl.haxx.se/)　　 　　：[7.69.1](https://curl.haxx.se/download/curl-7.69.1.tar.gz)

## 主机准备

使用以下脚本 

```bash
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make2.sh
#    Created  :  Tue 31 Mar 2020 10:09:09 AM CST

##
#!/bin/sh
HOST=arm-linux
BASE=`pwd`
OUTPUT_PATH=${BASE}/install
ARM_GCC=${HOST}-gcc


make_dirs () {
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
    tget https://curl.haxx.se/download/curl-7.69.1.tar.gz
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

make_curl () {
    cd ${BASE}/source/curl*
    ./configure --prefix=${OUTPUT_PATH}/${ZLIB} --host=${HOST} CC=${HOST}-gcc CXX=${HOST}-g++  && make && make install

}

make_dirs
download_package
tar_package
make_curl
```

## 拷贝

将`output`目录下的东西拷贝到板子上。

`lib` 拷贝进 `/usr/lib`中

运行 `./curl`进行测试
