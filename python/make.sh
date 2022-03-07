##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Tue 24 Dec 2019 04:20:51 PM CST

##
#!/bin/sh
PVERSION=3.6.10
source ../.common

download_python () {
    tget https://www.python.org/ftp/python/${PVERSION}/Python-${PVERSION}.tgz
}

make_host () {
    bash <<EOF
    cd ${BASE}/source/Python-${PVERSION}
    ./configure
    make && sudo make install
    #sudo rm /usr/bin/python
    #sudo ln -s /usr/local/bin/python3 /usr/bin/python
EOF
}

make_target () {
    bash <<EOF
    cd ${BASE}/source/Python-${PVERSION}
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
EOF
}

make_python_copy() {
    cd ${BASE}/source/
    cp ${BASE}/source/Python*  ${BASE}/source/Python*
}

make_dirs
download_python
tar_package
make_python_copy
#make_host
make_target
exit $?

以下内容针对开发板
/etc/profile 中添加
export PYTHONPATH= 　　　　　　　　　　　　 # 这一行是为了额外的模块的搜索，根据实际模块的使用情况进行填写，可留空，可参考附录进行填写
export PYTHONHOME=/mnt/nfs/python 　　　　 # 最终的安装路径，必须填写
