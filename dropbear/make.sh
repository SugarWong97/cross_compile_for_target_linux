##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
#    Created  :  Sat 30 Nov 2019 01:56:37 PM CST
##
#!/bin/sh

source ../.common
OPENSSL=openssl-1.0.2t
DROPBEAR=dropbear-2022.82
DROPBEAR_INSTALL=${OUTPUT_PATH}/${DROPBEAR}

#FIN_INSTALL=/usr/local

#下载包
download_dropbear () {
    get_zlib
    tget  https://matt.ucc.asn.au/dropbear/dropbear-2022.82.tar.bz2
}

# 删除不需要的Makefile的doc规则
# 这部分规则容易引起Makefile死循环
pre_make_ssl () {
    cd ${BASE}/source/${OPENSSL}
    startLine=`sed -n '/install_html_docs\:/=' Makefile`
    echo $startLine
    for startline in $startLine # 避免多行结果
    do
        endLine=`expr $startline + 999`
        sed -i $startline','$endLine'd' Makefile
        echo "install_html_docs:" >> Makefile
        echo -e "\t@echo skip by Schips" >> Makefile
        echo "install_docs:" >> Makefile
        echo -e "\t@echo skip by Schips" >> Makefile
        echo "# DO NOT DELETE THIS LINE -- make depend depends on it." >> Makefile
        break
    done
}

# 编译安装 ssl
make_ssl () {
    cd ${BASE}/source/${OPENSSL}
    echo "SSL ABOUT"
    CC=${_CC} ./config no-asm shared --prefix=${OUTPUT_PATH}/${OPENSSL}

    sed 's/-m64//g'  -i Makefile # 删除-m64 关键字 (arm-gcc 不支持)
    #sudo mv /usr/bin/pod2man /usr/bin/pod2man_bak
    #mv doc/apps /tmp/
    pre_make_ssl
    make $MKTHD && make install
}

## ssh 要求不能修改 prefix
do_copy () {
    cd ${BASE}/source/${OPENSSH}
    mkdir ${OUTPUT_PATH}/${OPENSSH}/bin -p
    mkdir ${OUTPUT_PATH}/${OPENSSH}/sbin -p
    mkdir ${OUTPUT_PATH}/${OPENSSH}/etc -p
    mkdir ${OUTPUT_PATH}/${OPENSSH}/libexec -p

    cp -v scp  sftp  ssh  ssh-add  ssh-agent \
        ssh-keygen  ssh-keyscan         ${OUTPUT_PATH}/${OPENSSH}/bin
    cp -v moduli ssh_config sshd_config ${OUTPUT_PATH}/${OPENSSH}/etc
    cp -v sftp-server  ssh-keysign      ${OUTPUT_PATH}/${OPENSSH}/libexec
    cp -v sshd                          ${OUTPUT_PATH}/${OPENSSH}/sbin

    #scp  sftp  ssh  ssh-add  ssh-agent  ssh-keygen  ssh-keyscan  拷贝到目标板/usr/local/bin
    #moduli ssh_config sshd_config拷贝到目标板 /usr/local/etc
    #sftp-server  ssh-keysign 拷贝到目标板 /usr/local/libexec
    #sshd 拷贝到目标板 /usr/local/sbin/
    echo "Copy all dirs under $FIN_INSTALL" > ${OUTPUT_PATH}/${OPENSSH}/install_path
}

make_key () {
    cd ${BASE}/source/${OPENSSH}
    ssh-keygen -t rsa   -f  ssh_host_key -N ""
    ssh-keygen -t rsa   -f  ssh_host_rsa_key -N ""
    ssh-keygen -t dsa   -f  ssh_host_dsa_key -N ""
    ssh-keygen -t ecdsa -f  ssh_host_ecdsa_key -N ""

    #将生成的 ssh_host_*_key这4个文件copy到目标板的 $FIN_INSTALL/etc/目录下
    cp ssh_host*key ${OUTPUT_PATH}/${OPENSSH}/etc
}

make_dropbear () {
    cd ${CODE_PATH}/${DROPBEAR}

    ./configure \
    --host=arm \
    --prefix=${DROPBEAR_INSTALL} \
    --with-zlib=${OUTPUT_PATH}/${ZLIB} \
    --enable-static \
    CC=${_CC} \
    AR=${_AR}

    make $MKTHD
    make scp
    make install
}

dropbear_help() {
cat <<EOF
-----------------------------------
in target:

    mkdir -p /usr/sbin/
    mkdir -p /etc/dropbear/

    cd <dropbear-path>
    cp bin/* sbin/* /usr/bin

    cd /etc/dropbear
    dropbearkey -t rsa -f dropbear_rsa_host_key
    dropbearkey -t dss -f dropbear_dss_host_key

    /usr/sbin/dropbear -p 22
EOF
}

cc_ssh ()
{
    make_dirs
    download_dropbear
    tar_package
    make_zlib || { echo >&2 "make_zlib "; exit 1; }
    #make_ssl  || { echo >&2 "make_ssl "; exit 1; }
    make_dropbear  || { echo >&2 "make_ssh "; exit 1; }
    #do_copy   || { echo >&2 "do_copy "; exit 1; }
    #make_key  || { echo >&2 "make_key "; exit 1; }
    dropbear_help
}
cc_ssh
