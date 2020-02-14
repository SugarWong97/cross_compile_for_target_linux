##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
#    Created  :  Sat 30 Nov 2019 01:56:37 PM CST
##
#!/bin/sh
BUILD_HOST=arm-linux-
ARM_GCC=${BUILD_HOST}gcc
BASE=`pwd`
OUTPUT_PATH=${BASE}/install
ZLIB=zlib-1.2.11
OPENSSL=openssl-1.0.2t
OPENSSH=openssh-4.6p1

FIN_INSTALL=/usr/${OPENSSH}
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
    #下载包
    tget  https://www.zlib.net/${ZLIB}.tar.gz
    tget  https://www.openssl.org/source/${OPENSSL}.tar.gz
    tget  http://mirrors.mit.edu/pub/OpenBSD/OpenSSH/portable/${OPENSSH}.tar.gz
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

make_zlib () {
    # 编译安装 zlib
    cd ${BASE}/source/${ZLIB}
    echo "ZLIB ABOUT"
    CC=${ARM_GCC} ./configure --prefix=${OUTPUT_PATH}/${ZLIB}
    make && make install
}

pre_make_ssl () {
    cd ${BASE}/source/${OPENSSL}
    startLine=`sed -n '/install_html_docs\:/=' Makefile`
    echo $startLine
    # 为了避免 多行结果
    for startline in $startLine
    do
        lineAfter=99
        endLine=`expr $startline + 999`
        sed -i $startline','$endLine'd' Makefile
        echo "install_html_docs:" >> Makefile
        echo "\t@echo skip by Schips" >> Makefile
        echo "install_docs:" >> Makefile
        echo "\t@echo skip by Schips" >> Makefile
        echo "# DO NOT DELETE THIS LINE -- make depend depends on it." >> Makefile
        break
    done
}

make_ssl () {
    # 编译安装 zlib
    cd ${BASE}/source/${OPENSSL}
    echo "SSL ABOUT"
    CC=${ARM_GCC} ./config no-asm shared --prefix=${OUTPUT_PATH}/${OPENSSL}

    sed 's/-m64//g'  -i Makefile # 删除-m64 关键字 (arm-gcc 不支持)
    #sudo mv /usr/bin/pod2man /usr/bin/pod2man_bak
    #mv doc/apps /tmp/
    pre_make_ssl
    make -j4 && make install
}

do_copy () {
    cd ${BASE}/source/${OPENSSH}
    mkdir ${OUTPUT_PATH}/${OPENSSH}/bin -p
    mkdir ${OUTPUT_PATH}/${OPENSSH}/sbin -p
    mkdir ${OUTPUT_PATH}/${OPENSSH}/etc -p
    mkdir ${OUTPUT_PATH}/${OPENSSH}/libexec -p

    cp scp  sftp  ssh  ssh-add  ssh-agent \
        ssh-keygen  ssh-keyscan         ${OUTPUT_PATH}/${OPENSSH}/bin
    cp moduli ssh_config sshd_config    ${OUTPUT_PATH}/${OPENSSH}/etc
    cp sftp-server  ssh-keysign         ${OUTPUT_PATH}/${OPENSSH}/libexec
    cp sshd                             ${OUTPUT_PATH}/${OPENSSH}/sbin



    #scp  sftp  ssh  ssh-add  ssh-agent  ssh-keygen  ssh-keyscan  拷贝到目标板/usr/local/bin
    #moduli ssh_config sshd_config拷贝到目标板 /usr/local/etc
    #sftp-server  ssh-keysign 拷贝到目标板 /usr/local/libexec
    #sshd 拷贝到目标板 /usr/local/sbin/
}

make_key () {
    cd ${BASE}/source/${OPENSSH}
    ssh-keygen -t rsa   -f  ssh_host_key -N ""
    ssh-keygen -t rsa   -f  ssh_host_rsa_key -N ""
    ssh-keygen -t dsa   -f  ssh_host_dsa_key -N ""
    ssh-keygen -t ecdsa -f  ssh_host_ecdsa_key -N ""

        #将生成的 ssh_host_*_key这4个文件copy到目标板的 /usr/local/etc/目录下
    cp ssh_host*key ${OUTPUT_PATH}/${OPENSSH}/etc
}


make_ssh () {
    cd ${BASE}/source/${OPENSSH}
    ./configure \
    --host=${BUILD_HOST} \
    --with-libs --with-zlib=${OUTPUT_PATH}/${ZLIB} \
    --with-ssl-dir=${OUTPUT_PATH}/${OPENSSL} \
    --disable-etc-default-login \
    CC=${BUILD_HOST}-gcc \
    AR=${BUILD_HOST}-ar

    make -j4 # 不需要 install
}

make_dirs
sudo ls
download_package
tar_package
make_zlib
make_ssl
make_ssh
do_copy
make_key
exit $?
