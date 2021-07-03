## 介绍

[i2c-tool](https://i2c.wiki.kernel.org/index.php/I2C_Tools)是一个专门调试i2c的开源工具。可获取挂载的设备及设备地址，还可以在对应的设备指定寄存器设置值或者获取值等功能，对于驱动以及应用开发者比较友好。

i2c-tool：[v3.0.3](https://mirrors.edge.kernel.org/pub/software/utils/)

## 移植

```bash
#
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#
#    File Name:  make.sh
#    Created  :  2020-10-17 09:38:39
#
#
#!/bin/sh

BASE=`pwd`
OUTPUT_PATH=${BASE}/install/

## 填写你的工具链名称
BUILD_HOST=arm-linux
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
    tget https://mirrors.edge.kernel.org/pub/software/utils/i2c-tools/i2c-tools-3.0.3.tar.xz
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

make_taget () {
    cd ${BASE}/source/*
    mkdir -p ${OUTPUT_PATH}/i2c-tools_arm
    CC=${BUILD_HOST}-gcc LD=${BUILD_HOST}-ld make
    make install prefix=${OUTPUT_PATH}/i2c-tools_arm
}

require ${BUILD_HOST}-gcc

make_dirs
tar_package
make_taget
exit $?
```

拷贝`install/i2c-tools_arm/sbin`中的文件即可运行。

```bash
i2c_tools/sbin# ls
i2c-stub-from-dump  i2cdetect           i2cdump             i2cget              i2cse
```

## 使用

为了避免混淆，假定拷贝好的`i2c-tools`已经配进`PATH`变量中。

```bash
-y ------- 取消用户交互，直接执行
-f ------- 强制执行
```



### 列举总线数目

```bash
# i2cdetect -l

i2c-1	i2c       	Cadence I2C at e0005000         	I2C adapter
i2c-0	i2c       	Cadence I2C at e0004000         	I2C adapter
```

### 查询i2c总线上设备及设备的地址

```bash
i2cdetect -y 0 # 例如总线 0

Error: Can't use SMBus Quick Write command on this bus
```

因为配置的问题，所以失败了。这里引用别人的结果：

```
i2cdetect -r -y 4                           
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- -- 
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
40: -- -- -- -- -- -- -- -- -- 49 -- -- -- -- -- -- 
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
```

可看出，在i2c 总线4上有1个设备地址为`0x40`

### 读取i2c上的设备寄存器

`i2cdump`命令可以列出整个设备的内容。

如果无法读取，则显示`XX`。

```bash
i2cdump -f  -y 1 0x68 
# 1 代表 i2c-1 总线
# 0x68 代表 设备地址
No size specified (using byte-data access)
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f    0123456789abcdef
00: 28 52 23 02 02 01 00 b3 40 20 71 04 96 28 48 03    (R#???.?@ q??(H?
10: 80 00 42 c8 05 02 40 30 20 00 20 08 00 55 44 22    ?.B???@0 . ?.UD"
20: 49 a9 24 28 48 10 44 20 21 f1 2d a2 04 00 43 8c    I?$(H?D !?-??.C?
30: 50 24 00 24 20 2c 14 20 01 a0 01 89 02 00 21 88    P$.$ ,? ?????.!?
40: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
50: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
60: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
70: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
80: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
90: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
a0: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
b0: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
c0: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
d0: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
e0: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
f0: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
```

`i2cget`可以读取一个值

```bash
i2cget -f -y 1 0x68  0x3f
# 0x3f 由 0x30 上的 f 得到，对应上面dump结果的 最后一个有效值。
88

i2cget -f -y 1 0x68  0
# 同理，得到上面的第一个有效值 28
28
```

### 写入值到i2c上的设备寄存器

```
i2cset -y -f 0 0x50 0x00 0x11
# 0：i2c-0
# 0x50 ： 设备地址
# 0x00 ：寄存器偏移
# 0x11 ：写入值
```