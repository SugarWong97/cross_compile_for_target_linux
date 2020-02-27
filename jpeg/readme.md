## 背景：

> host平台　　 ：Ubuntu 16.04
> arm平台　　 ： S5P6818
>
> [jpeg](http://www.ijg.org/) 　 　 ：[v9c](http://www.ijg.org/files/jpegsrc.v9c.tar.gz)
> arm-gcc　　 ：4.8.1

 

## 主机准备：

运行以下脚本：
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
JPEG=jpegsrc.v9c
OUTPUT=${BASE}/install/

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
    tget    http://www.ijg.org/files/${JPEG}.tar.gz
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

configure_jpeg () {
    cd ${BASE}/source/*
    ./configure \
    --prefix=${OUTPUT}/${JPEG} \
    --host=${BUILD_HOST}
}


make_jpeg () {
    cd ${BASE}/source/*make -j4 && make install
}
make_dirs
download_package
tar_package
configure_jpeg
make_jpeg
```



## 开发板准备
拷贝对应的库到板子上，使其在环境变量中能够找到对应的lib。
