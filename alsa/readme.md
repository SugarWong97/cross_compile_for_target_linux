
## 背景
Linux 有关 音频的开发。

**平台：**

> 　　host平台　　 ：Ubuntu 18.04
> 　　arm平台　　 ： S5P6818
> 　　arm-gcc　　 ：4.8.1
> 　　
> 　　alsa-lib 　   ：[1.0.22](ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.0.22.tar.bz2)
> 　　alsa-utils     ：[1.0.22](ftp://ftp.alsa-project.org/pub/utils/alsa-utils-1.0.22.tar.bz2)

## ALSA音频架构简单介绍

[ALSA](https://www.alsa-project.org/wiki/Download)是Advanced Linux Sound  Architecture，高级Linux声音架构的简称,它在Linux操作系统上提供了音频和MIDI（Musical Instrument  Digital  Interface，音乐设备数字化接口）的支持。在2.6系列内核中，ALSA已经成为默认的声音子系统，用来替换2.4系列内核中的OSS（Open Sound  System。开放声音系统）。ALSA的主要特性包含：高效地支持从消费类入门级声卡到专业级音频设备全部类型的音频接口，全然模块化的设计。 支持对称多处理（SMP）和线程安全。对OSS的向后兼容，以及提供了用户空间的alsa-lib库来简化应用程序的开发。

ALSA是一个全然开放源码的音频驱动程序集，除了像OSS那样提供了一组内核驱动程序模块之外，ALSA还专门为简化应用程序的编写提供了对应的函数库，与OSS提供的基于ioctl的原始编程接口相比。ALSA函数库使用起来要更加方便一些。利用该函数库，开发人员能够方便快捷的开发出自己的应用程序，细节则留给函数库内部处理。当然 ALSA也提供了类似于OSS的系统接口，只是ALSA的开发人员建议应用程序开发人员使用音频函数库而不是驱动程序的API。

 

**alsa-lib**是ALSA 应用库(必需基础库)，**alsa-utils**包含一些ALSA小的测试工具.如aplay、arecord 、amixer播放、录音和调节音量小程序，对于一些应用开发者只需要以上两个软件包就可以了。

 ## 移植

使用以下脚本进行编译：

```bash
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Mon 02 Sep 2019 11:39:38 AM HKT
##
#!/bin/zsh

BUILD_HOST=arm-linux

BASE=`pwd`
OUTPUT_PATH=${BASE}/install
ALSALIB_DIR=${OUTPUT_PATH}/alsa-lib

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
    tget ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.0.22.tar.bz2
    tget ftp://ftp.alsa-project.org/pub/utils/alsa-utils-1.0.22.tar.bz2
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

make_alsa_lib () {
    cd ${BASE}/source/alsa-lib*

     ./configure \
    --host=${BUILD_HOST} \
    --prefix=${OUTPUT_PATH}/alsa-lib \
    --enable-static \
    --enable-shared  \
    --disable-Python \
    --with-configdir=/usr/local/share
    #--with-plugindir=/usr/local/lib/alsa_lib

    sudo make && sudo make install
#关于配置参数的2点说明：
#(1)  如果需要自定义include/config.h中ALSA_CONFIG_DIR的值，可通过参数--with-configdir指定，即alsa.conf文件安装路径，默认值是--prefix下的/share/alsa/
#(2)  如果需要自定义include/config.h中ALSA_PLUGIN_DIR的值，可通过参数--with-plugindir指定，即smixer的安装路径，默认值是--prefix下的/lib/alsa-lib/
#在这里笔者建议：配置时最好用--with-configdir指定好alsa.conf文件安装路径，,不要让它在默认的输出路径中。这样方便在编译移植以后不会污染板子上的文件系统由于不希望修改root环境变量，所以在最后的make install 引入了环境变量
}


make_alsa_utils () {
    cd ${BASE}/source/alsa-utils*

    ./configure \
    --host=${BUILD_HOST} \
    --disable-alsamixer  \
    --disable-xmlto \
    CPPFLAGS=-I${ALSALIB_DIR}/include  \
    LDFLAGS=-L${ALSALIB_DIR}/lib  \
    --with-alsa-prefix=${ALSALIB_DIR}/lib  \
    --with-alsa-inc-prefix=${ALSALIB_DIR}/include  \
    --prefix=${OUTPUT_PATH}/alsa-utils

    make && make install
}
echo "Using ${BUILD_HOST}"
make_dirs
download_package
tar_package
make_alsa_lib
make_alsa_utils

```

## 开发板准备

**拷贝有关的文件**

alsa-lib

(1) 将参数--prefix指定的路径值/lib下的所有文件移植到arm linux系统的文件系统的/usr/lib/目录中

(2) 将share文件夹中的alsa文件夹复制（包括了alsa.conf）到arm linux系统的文件系统中的**/usr/local/****share （这个路径由 --with-configdir 参数指定）** 

(3) 其它内容可选，但是如果移植，那么它们在arm linux系统中的目录路径必须和其在pc机上的安装路径相同



alsa-utils

(1) 将参数--prefix指定的路径值/bin/目录中的文件移植到arm linux系统中的/usr/bin或其它目录中，如果移植到其它目录中，则需要将该目录添加到环境变量PATH指的执行路径中

(2) 将参数--prefix指定的路径值/sbin/目录中的文件移植到arm linux系统中的/usr/bin或其它目录中，如果移植到其它目录中，则需要将该目录添加到环境变量PATH指的执行路径中

(3) 其它内容可选，但是如果移植，那么它们在arm linux系统中的目录路径必须和其在pc机上的安装路径相同

 

**创建有关的设备文件**

使用以下脚本：

```bash
#!/bin/sh

mkdir /dev/snd
cd /dev/snd

mknod mixer c 14 0
mknod dsp   c 14 3
mknod audio c 14 4

mknod controlC0 c 116 0
mknod seq       c 116 1

mknod pcmC0D0p c 116 16
mknod pcmC0D1p c 116 17
mknod pcmC0D0c c 116 24
mknod pcmC0D1c c 116 25

mknod timer    c 116 33


# 对于有关设备的解释
   controlC0 :用于声卡的控制，如麦克风的控制或者混音的控制；
   pcmC0D0c：用于录音的pcm设备；
   pcmC0D0p：用于播放的pcm设备；
   Seq： 音序器；
   Timer：定时器；
```

​    


**测试：**

录音

```bash
arecord -d3 -c1 -r16000 -twav -fS16_LE example.wav

说明：
-d：录音时长（duration） 秒
-c：音轨（channels）
-r：采样频率（rate） 每一秒采集多少个样本
-t：封装格式（type）
-f：量化位数（format）16bit 小端
```



播放

```bash
aplay example.wav
```

 

