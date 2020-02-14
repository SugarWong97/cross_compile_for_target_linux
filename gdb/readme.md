## 背景
调试工具gdb的使用对于嵌入式Linux开发人员来说是一项不可少的技能。
目前，嵌入式 Linux系统中，主要有三种远程调试方法，分别适用于不同场合的调试工作：_用ROM Monitor调试目标机程序、用KGDB调试系统内核和用gdbserver调试用户空间程序_。
这三种调试方法的区别主要在于，目标机远程调试stub 的存在形式的不同，而其设计思路和实现方法则是大致相同的。
我们最常用的是调试应用程序。就是采用gdb+gdbserver的方式进行调试。在很多接在情况下，用户需要对一个应用程序进行反复调试，特别是复杂的程 序。采用GDB方法调试，由于嵌入式系统资源有限性，一般不能直目标系统上进行调试，通常采用gdb+gdbserver的方式进行调试。 Gdbserver在目标系统中运行，gdb则在宿主机上运行。

要进行GDB调试，目标系统必须包括gdbserver程序，宿主机也必须安装gdb程序（目前似乎也可以用ARM的DS-5工具来替换宿主机的GDB，实现可视化调试）。一般linux发行版中都有一个可以运行的gdb，但开发人员 不能直接使用该发行版中的gdb来做远程调试，而要获取gdb的源代码包，针对arm平台作一个简单配置，重新编译得到相应gdb。
 
[gdb](http://ftp.gnu.org/gnu/gdb/)  : [v7.81](http://ftp.gnu.org/gnu/gdb/gdb-7.8.1.tar.xz)

## 编译
一个脚本完成所有的事情。

```bash
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Tue 24 Dec 2019 04:20:51 PM CST

##
#!/bin/sh
BASE=`pwd`
BUILD_HOST=arm-linux


OUTPUT=${BASE}/install/

make_dirs() {
    cd ${BASE}
    mkdir  compressed  install  source -p
    sudo ls
}

download_package () {
    cd ${BASE}/compressed
    #下载包
    wget http://ftp.gnu.org/gnu/gdb/gdb-7.8.1.tar.xz
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
make_gdb_host () {
    cd ${BASE}/source/gdb*
    ./configure --target=${BUILD_HOST} --prefix=${OUTPUT}/gdb_host
    make && make install

}

make_gdb_target () {
    cd ${BASE}/source/gdb*/gdb/gdbserver
    ./configure --host=${BUILD_HOST} --prefix=${OUTPUT}/gdbserver
    make && make install
}


make_dirs
#download_package
tar_package
# arm gdb 分为2个部分
make_gdb_host
make_gdb_target
exit $?

```
##测试
将编译生成的 gdbserver 复制到目标板/usr/sbin上，修改执行权限，然后测试一个简单的helloworld程序：
###板子上
```
gdbserver  <host ip : 端口> <程序名>

例如：
$ gdbserver 192.168.1.100:5000 helloworld                 # 启动调试，等待主机连接
Process helloworld created; pid = 698
Listening on port 5000
```
###主机
运行以下命令进入gdb调试的界面（以arm-linux-gcc工具链为例）
```bash
arm-linux-gdb  <程序名>
```
输入交互式命令：
```
(gdb)target remote <target-board-ip：端口> 
```
![](https://img2018.cnblogs.com/blog/1281523/201912/1281523-20191230162631520-370078973.png)


此后，使用gdb命令开始调试即可

