## 背景
QT 在 开发中很常见。

平台        ： Ubuntu 16.04

[QT ](http://mirrors.ustc.edu.cn/qtproject/archive/qt/)         ：[5.9.8](http://mirrors.ustc.edu.cn/qtproject/archive/qt/5.9/5.9.8/single/qt-everywhere-opensource-src-5.9.8.tar.xz)

[tslib](https://www.cnblogs.com/schips/p/ https://github.com/libts/tslib/releases/tag/1.4)         ： [1.4](https://github.com/libts/tslib/releases/download/1.4/tslib-1.4.tar.bz2 )
arm-gcc     ： 4.8.1 （ > 4.8 ）


## 主机准备：

一个脚本做完所有的事情

```bash
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make_QT5.9.sh
#    Created  :  Fri 22 Nov 2019 11:49:30 AM CST

##
#!/bin/sh
BASE=`pwd`
BUILD_HOST=arm-linux
XPLATFORM=linux-diy-arm-g++

OUTPUT=${BASE}/install/

make_dirs() {
    cd ${BASE}
    mkdir  compressed  install  source -p
}

setup_env () {
    sudo apt-get install autoconf automake autogen libtool libsysfs-dev -y
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
    tget https://github.com/libts/tslib/releases/download/1.4/tslib-1.4.tar.bz2
    tget http://mirrors.ustc.edu.cn/qtproject/archive/qt/5.9/5.9.8/single/qt-everywhere-opensource-src-5.9.8.tar.xz
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

do_fix () {
    cd ${BASE}/source/tslib*
    echo "#define ABS_MT_SLOT            0x2f   /* MT slot being modified */"                >> config.h
    echo "#define ABS_MT_TOUCH_MAJOR     0x30   /* Major axis of touching ellipse */"        >> config.h
    echo "#define ABS_MT_TOUCH_MINOR     0x31   /* Minor axis (omit if circular) */"         >> config.h
    echo "#define ABS_MT_WIDTH_MAJOR     0x32   /* Major axis of approaching ellipse */"     >> config.h
    echo "#define ABS_MT_WIDTH_MINOR     0x33   /* Minor axis (omit if circular) */"         >> config.h
    echo "#define ABS_MT_ORIENTATION     0x34   /* Ellipse orientation */"                   >> config.h
    echo "#define ABS_MT_POSITION_X      0x35   /* Center X touch position */"               >> config.h
    echo "#define ABS_MT_POSITION_Y      0x36   /* Center Y touch position */"               >> config.h
    echo "#define ABS_MT_TOOL_TYPE       0x37   /* Type of touching device */"               >> config.h
    echo "#define ABS_MT_BLOB_ID         0x38   /* Group a set of packets as a blob */"      >> config.h
    echo "#define ABS_MT_TRACKING_ID     0x39   /* Unique ID of initiated contact */"        >> config.h
    echo "#define ABS_MT_PRESSURE        0x3a   /* Pressure on contact area */"              >> config.h
    echo "#define ABS_MT_DISTANCE        0x3b   /* Contact hover distance */"                >> config.h
    echo "#define ABS_MT_TOOL_X          0x3c   /* Center X tool position */"                >> config.h
    echo "#define ABS_MT_TOOL_Y          0x3d   /* Center Y tool position */"                >> config.h
    sed -i 'N;20a\#include \"config.h\"' tools/ts_uinput.c
    make
}

make_tslib () {
    cd ${BASE}/source/tslib*
    make clean
    make distclean
    echo "ac_cv_func_malloc_0_nonnull=yes" > arm-linux.cache

    CC=${BUILD_HOST}-gcc \
    ./configure --host=arm-linux \
    --prefix=${OUTPUT}/tslib \
    --cache-file=arm-linux.cache  \
    ac_cv_func_malloc_0_nonnull=yes  --enable-inputapi=no
    make  || do_fix
    make install
}

pre_configure_xplatform () {
    cd ${BASE}/source/qt*
    [ -d  qtbase/mkspecs/${XPLATFORM} ] && rm qtbase/mkspecs/${XPLATFORM} -r
    cp qtbase/mkspecs/linux-arm-gnueabi-g++ -r qtbase/mkspecs/${XPLATFORM}
    cd qtbase/mkspecs/${XPLATFORM}

    # qmake.conf
    sed -r -i "/QMAKE_CC/ s/.*/QMAKE_CC \t\t= ${BUILD_HOST}-gcc/"               qmake.conf
    sed -r -i "/QMAKE_CXX/ s/.*/QMAKE_CXX \t\t= ${BUILD_HOST}-g++/"             qmake.conf
    sed -r -i "/QMAKE_LINK / s/.*/QMAKE_LINK \t\t= ${BUILD_HOST}-g++/"          qmake.conf
    sed -r -i "/QMAKE_LINK_SHLIB/ s/.*/QMAKE_LINK_SHLIB \t= ${BUILD_HOST}-g++/" qmake.conf

    sed -r -i "/QMAKE_AR/ s/.*/QMAKE_AR \t\t= ${BUILD_HOST}-ar cqs/"            qmake.conf
    sed -r -i "/QMAKE_OBJCOPY/ s/.*/QMAKE_OBJCOPY \t\t= ${BUILD_HOST}-objcopy/" qmake.conf
    sed -r -i "/QMAKE_NM/ s/.*/QMAKE_NM \t\t= ${BUILD_HOST}-nm -P/"             qmake.conf
    sed -r -i "/QMAKE_STRIP/ s/.*/QMAKE_STRIP \t\t= ${BUILD_HOST}-strip/"       qmake.conf

    #sed -i 'N;20a\QMAKE_INCDIR += ${OUTPUT}/tslib/include' qmake.conf
    #sed -i 'N;20a\QMAKE_LIBDIR += ${OUTPUT}/tslib/lib'     qmake.conf
    
}

configure_qt () {
    cd ${BASE}/source/qt*
    ./configure \
    -v \
    -prefix ${OUTPUT}/qt \
    -release \
    -opensource \
    -confirm-license \
    -xplatform ${XPLATFORM} \
    -nomake examples -nomake tools \
    -optimized-qmake \
    -no-cups \
    -pch \
    -qt-zlib \
    -qt-sqlite \
    -tslib \
    -no-opengl \
    -no-sse2 \
    -no-openssl \
    -no-glib \
    -no-cups \
    -recheck-all \
    -no-separate-debug-info \
    -no-pkg-config \
    -skip qt3d \
    -skip qtcanvas3d \
    -skip qtdeclarative \
    -no-iconv \
    -I${OUTPUT}/tslib/include  -L${OUTPUT}/tslib/lib | tee ${BASE}/install/qt_configure_information
}

make_qt () {
    cd ${BASE}/source/qt*
    make -j4 && make install
}

make_dirs
setup_env
download_package
tar_package
make_tslib
pre_configure_xplatform
configure_qt
make_qt
```


## 部署开发板的环境

将install下的2个目录 拷贝到开发板的文件系统中，建议是放在 /usr 。（下面以/usr目录为例）

 

在`/etc/profile` 中加入以下片段：


```bash
#ts lib

export TS_ROOT=/usr/tslib1.4

export TSLIB_CONFFILE=$TS_ROOT/etc/ts.conf
export TSLIB_PLUGINDIR=$TS_ROOT/lib/ts
export TSLIB_TSDEVICE=/dev/input/event0
export TSLIB_CALIBFILE=/etc/pointercal
export TSLIB_CONSOLEDEVICE=none
export TSLIB_FBDEVICE=/dev/fb0

export LD_LIBRARY_PATH=$TS_ROOT/lib:$LD_LIBRARY_PATH
#qt
export QTDIR=/usr/qt-5.9.8
export QT_QPA_FONTDIR=$QTDIR/lib/fonts
export QT_QPA_PLATFORM_PLUGIN_PATH=$QTDIR/plugins
export QT_QPA_PLATFORM_PATH=$QTDIR/plugins
export QT_QPA_PLATFORM=linuxfb:fb=/dev/fb0:size=800x480:mmSize=800x480:offset=0x0:tty=/dev/tty1
export QMLSCENE_DEVICE=softwarecontext
export QML2_IMPORT_PATH=$QTDIR/qml
export QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS=/dev/input/event0
export QT_QPA_FB_TSLIB=1export QT_QPA_GENERIC_PLUGINS=tslib
export LD_LIBRARY_PATH=$QTDIR/lib:$LD_LIBRARY_PATHexport PATH=$QTDIR/bin:$PATH
```

验证tslib是否移植成功：
　　执行tslib1.4/bin 下的任意可执行文件，即可知道执行情况。

 

## QT-creator添加新的arm-gcc

***安装QT（[Ubuntu 安装 QtCreator (version : Qt 5.9.8)](https://www.cnblogs.com/schips/p/12029921.html)）***

***注意：下文图示中，有可能在实际操作过程会遇到红色感叹号，其实是正常的。***

### **QT配置：**

#### **添加QMAKE：**

“Tools”-“Options”-“Build & Run”-“Qt Versions”，点击Add添加qmake路径

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212173712066-583650743.png)

 

点击 Apply。

 

#### **添加Compilers：**

**“Tools”-“Options”-“kits” - "Compilers"
**

选择 Add - > GCC 。依次选择 C/C++ ，并添加板子对应的arm-gcc/g++

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174943863-938290067.png)


 点击 Apply。


#### **添加debugers：（可选项）**

**“Tools”-“Options”-“kits” - "\**debugers\**"** 

添加Debugers 与 Compilers 同理，不再赘述，配置以后点击 Apply

 

#### **添加Devices：**

**“Tools”-“Options”-“Devices”** 

注意：先将开发板与电脑连接到同一局域网，并查看开发板 IP 地址。
在点取菜单栏的"Tools->Options"，选取 Devices 选项。点击 Add 添加。选取第一个"Generic Linux Devive"选项，点击"Start Wizard"选取。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212173813115-881946723.png)

 
给开发板取个名字，再填上开发板的 IP 地址和用户名，密码，点击 Next。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174012063-460564737.png)


点击 Finish 开始连接开发板，当出现"Device test finished successfully"字样说明连接成功。点击 Closed。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174035294-1070775587.png)

 

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174120679-1998308129.png)


点击"Create new…"， Key algotithm 选取 RSA， Key size 选取 1024，点击"Generate And Save Key Pair"。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174225033-1565490743.png)


点击"Do Not Encrypt Key File"。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174254887-1093178008.png)


点击"Deploy public Key"，打开 qtc_ip.pub，显示"Deployment finished successfully"则表示设备配置成功。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174413386-1424765712.png)

 点击 Apply 

 

#### 添加工具集：

**“Tools”-“Options”-“Kits” 
**

注意： 不同的QT版本这个选项的位置不同，有些在 “Tools”-“Options”-“Build & Run”这里 。

点击Add，选择上文配置的，具体如下： 

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212175320777-1823826370.png)

 
 QT编译以后，提示以下错误：（此项只影响能否在板子上显示正在开发中的程序）

```
SFTP initialization failed: Server could not start SFTP subsystem.
```

只需要找到 板子 sshd 对应的配置文件sshd_config，设置好正确的sftp-server路径即可

```
Subsystem sftp /usr/local/libexec/sftp-server 
```

## 测试

新建QT工程，勾选新添加的 Kits，之后编译运行即可。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212175806788-1080079244.png)


正确配置好以后，点击运行即可在开发板连接的屏幕上看到结果了。
