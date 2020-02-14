## 背景：

　　人生苦短，我用Python。

**说明：**

　　编译Python的嵌入式版需要解释器解析setup.py从而编译Python的模块，因此需要先编译出host的解释器。（有点像Go语言）

　　[Python](https://www.python.org/downloads/source/) 　　: [Python 3.7.6 ](https://www.python.org/ftp/python/3.7.6/Python-3.7.6.tgz)

 

##  编译：



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
    wget https://www.python.org/ftp/python/3.7.6/Python-3.7.6.tgz
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

make_host () {
    cd ${BASE}/source/Python*
    ./configure
    make && sudo make install
    sudo rm /usr/bin/python
    sudo ln -s /usr/local/bin/python3 /usr/bin/python
}
make_target () {
    cd ${BASE}/source/Python*
    echo `pwd`
    sudo make clean
    mkdir bulid-${BUILD_HOST} -p
    cd  bulid-${BUILD_HOST}
    mkdir ${BASE}/install/python -p
    ../configure CC=${BUILD_HOST}-gcc \
    CXX=${BUILD_HOST}-g++ \
    --host=${BUILD_HOST} \
    --build=x86_64-linux-gnu \
    --target=${BUILD_HOST} --disable-ipv6 \
    --prefix=${BASE}/install/python \
    --enable-optimizations \
    ac_cv_file__dev_ptmx=yes ac_cv_file__dev_ptc=yes
    make && make install
}
make_dirs
download_package
tar_package
#make_host 如果没有的话，需要安装
make_target
```

 

## 部署：

将编译生成的python目录放到目标板中，添加以下环境变量：

（假设 python 目录放在 /mnt/nfs/python）

```
export PATH=$PATH:/mnt/nfs/python/bin 　　# 用于执行python，填写 Python目录中的Bin目录即可export PYTHONPATH= 　　　　　　　　　　　　  # 这一行是为了额外的模块的搜索，根据实际模块的使用情况进行填写，可留空，可参考附录进行填写
export PYTHONHOME=/mnt/nfs/python 　　　　 # 最终的安装路径，必须填写
```

（如果不添加，会导致；关于这里可以参考：根据：https://askubuntu.com/questions/905372/could-not-find-platform-independent-libraries-prefix）

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
Fatal Python error: initfsencoding: unable to load the file system codecModuleNotFoundError: No module named 'encodings'Current thread 0xb6f28000 (most recent call first):Aborted有关的解释是这样的：
```

 必须设置2个环境变量 PYTHONPATH 与 PYTHONHOME.因为python3解释器搜索有关库时依赖这2个变量：

 PYTHONPATH 作为 模块 的默认搜索路径 (The PYTHONPATH variable augments the default search path for module files.)

 PYTHONHOME 用于 python标准库(PYTHONHOME is used for standard python libraries. )，

 设置变量的格式以shell格式即可，例如

```py
export PYTHONPATH='/path/to/pythondir:/path/to/pythondir/lib-dynload:/path/to/pythondir/site-packages'
export PYTHONHOME=/path/to/pythondir
```



 

**最终结果：**

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191230172422748-309242003.png)

 

 

 

 

 

 

## 附录：**有关错误信息以及处理办法**

**$PYTHONPATH路径问题**

错误信息： 

```
ImportError: No module named site
```

解决：

a.查找site相关路径

```
find / -name site.py*
/usr/lib64/python2.7/site.pyc
/usr/lib64/python2.7/site.py
/usr/lib64/python2.7/site.pyo
```

b.将路径添加到$PYTHONPATH中

```
export PYTHONPATH=$PYTHONPATH:/usr/lib64/python2.7
```
