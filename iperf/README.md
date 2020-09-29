## 背景
新做的硬件需要有进行一些板级接口测试；关于网络的测试很多时候只是停留在 `ping 通`；能够使用就算了。不知道网络的丢包率，也不知道网络吞吐的性能。

因此，需要使用一些专业化的工具来进行测试；查阅有关资料，发现了一个测试工具 iperf。

[iperf](https://github.com/esnet/iperf)是一个基于Client/Server的网络性能测试工具，可以帮助我们测试网络性能，定位网络瓶颈。其中抖动和丢包率适应于UDP测试，二带宽测试适应于TCP和UDP：
- TCP、UDP和SCTP带宽质量，
- 提供网络吞吐率信息，
- 震动、丢包率，最大段和最大传输单元大小
- 其他统计信息

使用方法：[使用iperf调试网络](https://www.cnblogs.com/schips/p/using-iperf-debug-network.html)

## 移植
老生常谈，一个脚本搞定。

```bash
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Mon 28 Setp 2020 14:29:31 PM CST

##
#!/bin/sh
BASE=`pwd`
BUILD_HOST=arm-linux
export PATH=${PATH}:/opt/gcc-arm-linux-gnueabi/bin

OUTPUT_PATH=${BASE}/install/

require () {
    if [ -z "$1" ];then
        return 
    fi
    command -v $1 >/dev/null 2>&1 || { echo >&2 "Aborted : Require \"$1\" but not found."; exit 1;   }
    echo "Using: $1"
}

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

tar_package () {
    cd ${BASE}/compressed
    ls * > /tmp/list.txt
    for TAR in `cat /tmp/list.txt`
    do
        tar -xf $TAR -C  ../source
    done
    rm -rf /tmp/list.txt
}

download_package () {
    cd ${BASE}/compressed
    #下载包
    ## http://downloads.es.net/pub/iperf/
    tget    https://downloads.es.net/pub/iperf/iperf-3.6.tar.gz
}

set_compile_env_for_arm () {
	export CC=${BUILD_HOST}-gcc
	export AR=${BUILD_HOST}-ar
	export LD=${BUILD_HOST}-ld
	export RANLIB=${BUILD_HOST}-ranlib
	export STRIP=${BUILD_HOST}-strip
}

make_iperf_host () {
    cd ${BASE}/source/*
    ./configure --prefix=${OUTPUT_PATH}/iperf_host 
    make clean
    make -j4 && make install
}

make_iperf_target () {
    cd ${BASE}/source/*
    ./configure --host=${BUILD_HOST} --prefix=${OUTPUT_PATH}/iperf_target 
    make clean
    make -j4 && make install
}

require ${BUILD_HOST}-gcc

make_dirs
download_package
tar_package
make_iperf_host
set_compile_env_for_arm
make_iperf_target
```

## 拷贝
此后，在inistall目录中 生成2种iperf：
- iperf_target : 板子上运行。
- iperf_host   : 在PC机上面运行

拷贝 iperf_target 中的 `lib/*` 到 板子上的 LD_LIBRARY_PATH 包括的路径中即可（例如`/lib`） 中，拷贝 `bin`中的程序到 PATH包括的路径中即可（例如`/bin`），此后运行，参考文前给出的链接。
