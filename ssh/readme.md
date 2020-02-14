## 背景：
自己拥有一块开发板，但是苦于上面没有ssh，比较不方便。正好趁这个机会，移植ssh。我们使用的ssh是openssh。

host平台　　 ：Ubuntu 18.04

arm平台　　 ： S5P6818

 

openssh  　  ：4.6p1

openssl　　  ：0.9.8e

zlib　　　　  ：1.2.11


arm-gcc　　 ：4.8.1

 

 

## 准备
一个脚本做完所有的事情



```bash
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
#    Created  :  Sat 30 Nov 2019 01:56:37 PM CST
##
#!/bin/sh

BUILD_HOST=arm-linux
ARM_GCC=${BUILD_HOST}-gcc
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

download_package () {
    cd ${BASE}/compressed
    #下载包
    wget -c https://www.zlib.net/${ZLIB}.tar.gz
    wget    https://www.openssl.org/source/${OPENSSL}.tar.gz
    wget -c http://mirrors.mit.edu/pub/OpenBSD/OpenSSH/portable/${OPENSSH}.tar.gz
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
    ./Configure --prefix=${OUTPUT_PATH}/${OPENSSL}  os/compiler:${ARM_GCC}
    #sudo mv /usr/bin/pod2man /usr/bin/pod2man_bak
    #mv doc/apps /tmp/
    pre_make_ssl
    make && make install
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
```



 

## 开发板准备

新建以下目录

```bash
mkdir -p /usr/local/bin/
mkdir -p /usr/local/sbin/
mkdir -p /usr/local/etc/
mkdir -p /usr/local/libexec/
mkdir -p /var/run/
mkdir -p /var/empty/
```



拷贝：
从PC机上将以下文件拷贝到目标板Linux系统中


PC机 ssh/source/openssh-4.6p1/ 目录下的

- scp  sftp  ssh  ssh-add  ssh-agent  ssh-keygen  ssh-keyscan  拷贝到目标板/usr/local/bin
- moduli ssh_config sshd_config拷贝到目标板 /usr/local/etc
- sftp-server  ssh-keysign 拷贝到目标板 /usr/local/libexec
- sshd 拷贝到目标板 /usr/local/sbin/



生成Key文件
在PC机 ssh/source/openssh-4.6p1/ 目录下运行：

```
ssh-keygen -t rsa -f ssh_host_key -N ""
ssh-keygen -t rsa -f ssh_host_rsa_key -N ""
ssh-keygen -t dsa -f ssh_host_dsa_key -N ""
ssh-keygen -t ecdsa -f ssh_host_ecdsa_key -N ""
```

将生成的 ssh_host_*_key这4个文件copy到目标板的 /usr/local/etc/目录下

 

修改目标板passwd文件

在/etc/passwd 中添加下面这一行 “ sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin ”

```
cp /etc/passwd  /etc/passwd_bak
echo "sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin" >> /etc/passwd
```

 


此后，只需要运行一次 /usr/local/sbin/sshd 此后即可使用远程登录

如果开发板的 root 用户还没有密码，键入以下命令然输入两次密码来修改，否则其他设备无法连接：

```
passwd root
```


如果连接不上，请直接运行 /usr/local/sbin/sshd 查看是什么原因

- 有提示 动态链接库 找不到的（工具链的动态链接库）
- 有提示 ssh_host 文件找不到的 生成即可

 

## 开发板设置开机自启动ssh：

/etc/init.d目录下新建S**xx**sshd.sh文件 (xx 指的是具体的数字，可任意，一般越晚后越好)



```
#! /bin/sh
sshd=/usr/local/sbin/sshd
test -x "$sshd" || exit 0
case "$1" in
  start)
    echo -n "Starting sshd daemon"
    start-stop-daemon --start --quiet --exec $sshd  -b
    echo "."
    ;;
  stop)
    echo -n "Stopping sshd"
    start-stop-daemon --stop --quiet --exec $sshd
    echo "."
    ;;
  restart)
    echo -n "Stopping sshd"
    start-stop-daemon --stop --quiet --exec $sshd
    echo "."
    echo -n "Waiting for sshd to die off"
    for i in 1 2 3 ;
    do
        sleep 1
        echo -n "."
    done
    echo ""
    echo -n "Starting sshd daemon"
    start-stop-daemon --start --quiet --exec $sshd -b
    echo "."
    ;;
  *)
    echo "Usage: /etc/init.d/sshd {start|stop|restart}"
    exit 1
esac
exit 0
```

 
