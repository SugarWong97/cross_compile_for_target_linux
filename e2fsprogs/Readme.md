## 背景

之前在zynq平台下处理系统分区，用到了SPI-FLASH以及EMMC。

根据ZYNQ平台的特性以及产品升级需要，规划了

- SPI-FLASH放置BootLoader
- EMMC中分为2个区，一个FAT放置内核、一个EXT4存放文件系统

因为发现默认的文件系统中没有`mkfs.ext4`的命令，因此需要自己移植，而这个程序连同`mkfs.ext2`、`mkfs.ext3`被包含在`e2fsprogs`中。

> [e2fsprogs](https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/)　　 　　：[1.45.6](https://udomain.dl.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.45.6/e2fsprogs-1.45.6.tar.gz)

## 移植

还是一个脚本搞定的事情。

```bash
#/** @file         make.sh
#*  @author       Schips
#*  @date         2020-10-28 23:22:53
#*  @version      v1.0
#*  @copyright    Copyright By Schips, All Rights Reserved
#*
#**********************************************************
#*
#*  @par 修改日志:
#*  <table>
#*  <tr><th>Date       <th>Version   <th>Author    <th>Description
#*  <tr><td>2020-10-28 <td>1.0       <td>Schips    <td>创建初始版本
#*  </table>
#*
#**********************************************************
#*/

#!/bin/sh

BUILD_HOST=arm-linux
BASE=`pwd`
OUTPUT_PATH=${BASE}/install/
## 必要时，填写你的工具链的所在路径
BUILD_HOST_PATH=/opt/gcc-arm-linux-gnueabi/bin
export PATH=${PATH}:${BUILD_HOST_PATH}

require () {
    if [ -z "$1" ];then
        return 
    fi
    command -v $1 >/dev/null 2>&1 || { echo >&2 "Aborted : Require \"$1\" but not found."; exit 1;   }
    echo "Using: $1"
}
make_dirs () {
    #为了方便管理，创建有关的目录
    cd ${BASE} && mkdir compressed install source -p
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
    tget https://udomain.dl.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.45.6/e2fsprogs-1.45.6.tar.gz
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

make_e2fsprogs () {
    cd ${BASE}/source/e2fsprogs*
    mkdir configure_dir -p
    cd configure_dir
    CC=${BUILD_HOST}-gcc ../configure --host=arm-linux --enable-elf-shlibs \
        --prefix=${OUTPUT_PATH}/e2fsprogs \
        --datadir=${OUTPUT_PATH}/e2fsprogs/doc \
		--with-udev-rules-dir=${OUTPUT_PATH}/e2fsprogs \
		--with-crond-dir=${OUTPUT_PATH}/e2fsprogs \
		--with-systemd-unit-dir=${OUTPUT_PATH}/e2fsprogs
    make && make install
}

require ${BUILD_HOST}-gcc
make_dirs
download_package
tar_package
make_e2fsprogs
exit $?

```

## 拷贝

拷贝`install/e2fsprogs/sbin`到板子`/usr/sbin`中

拷贝`install/e2fsprogs/lib`到板子`/usr/lib`中

运行即可，例如：

```bash
# mkfs.ext4 /dev/mmcblk1p2
```