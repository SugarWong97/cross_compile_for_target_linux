#OPENSSH=openssh-6.6p1
OPENSSH=openssh-9.1p1

FIN_INSTALL=/usr/local

#下载包
download_ssh () {
    get_zlib
    tget  https://www.openssl.org/source/${OPENSSL}.tar.gz
    tget  http://mirrors.mit.edu/pub/OpenBSD/OpenSSH/portable/${OPENSSH}.tar.gz
}

# 删除不需要的Makefile的doc规则
# 这部分规则容易引起Makefile死循环
pre_make_ssl () {
    cd ${CODE_PATH}/${OPENSSL}
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
    cd ${CODE_PATH}/${OPENSSL}
    echo "SSL ABOUT"
    pwd
    CC=${_CC} ./config no-asm shared --prefix=${OUTPUT_PATH}/${OPENSSL}

    sed 's/-m64//g'  -i Makefile # 删除-m64 关键字 (arm-gcc 不支持)
    #sudo mv /usr/bin/pod2man /usr/bin/pod2man_bak
    #mv doc/apps /tmp/
    pre_make_ssl
    make $MKTHD && make install
}


## ssh 要求不能修改 prefix
do_copy_for_openssn () {
    cd ${CODE_PATH}/${OPENSSH}
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
    # 拷贝其他脚本、配置
    mkdir -p ${OUTPUT_PATH}/others
    rm ${OUTPUT_PATH}/others/* -rf
    cp ${BASE}/meta/*  ${OUTPUT_PATH}//others
}

make_key_openssh () {
    cd ${CODE_PATH}/${OPENSSH}
    ssh-keygen -t rsa       -f  ssh_host_key -N         ""
    ssh-keygen -t rsa       -f  ssh_host_rsa_key -N     ""
    ssh-keygen -t dsa       -f  ssh_host_dsa_key -N     ""
    ssh-keygen -t ecdsa     -f  ssh_host_ecdsa_key -N   ""
    ssh-keygen -t ed25519   -f  ssh_host_ed25519_key -N ""

    #将生成的 ssh_host_*_key这4个文件copy到目标板的 $FIN_INSTALL/etc/目录下
    cp ssh_host*key ${OUTPUT_PATH}/${OPENSSH}/etc
}

mk_ssh () {

    # 如果ssl是so库，在后续的很多时候都会需要考虑环境变量的问题
    echo "ALLOW STATIC LINK ONLY"
    rm -v -rf ${OUTPUT_PATH}/${OPENSSL}/lib/*.so*

    bash <<EOF
    cd ${CODE_PATH}/${OPENSSH}
    ./configure \
    --host=${BUILD_HOST} \
    --build=i386 \
    --prefix=${FIN_INSTALL} \
    --with-libs --with-zlib=${OUTPUT_PATH}/${ZLIB} \
    --with-ssl-dir=${OUTPUT_PATH}/${OPENSSL} \
    --disable-etc-default-login \
    CC=${_CC} \
    AR=${_AR}

    make $MKTHD # 不能执行 install
EOF
}

gen_target_linux_cmd_openssh () {
    (
    cat <<EOF
mkdir -vp /usr/local/bin/
mkdir -vp /usr/local/lib/
mkdir -vp /usr/local/sbin/
mkdir -vp /usr/local/etc/
mkdir -vp /usr/local/libexec/
mkdir -vp /var/run/
mkdir -vp /var/empty/

cp -rfv  ${OPENSSH}/*          ${FIN_INSTALL}/
cp -rfv  ${OPENSSL}/lib/*.so*  ${FIN_INSTALL}/lib/
cp -rfv  ${ZLIB}/lib/*.so*     ${FIN_INSTALL}/lib/

cp /etc/passwd  /etc/passwd_bak
echo "sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin" >> /etc/passwd

EOF
) > ${OUTPUT_PATH}/install_helper
    chmod +x ${OUTPUT_PATH}/install_helper
}

make_ssh ()
{
    download_ssh
    tar_package
    #make_zlib || { echo >&2 "make_zlib "; exit 1; }
    make_ssl  || { echo >&2 "make_ssl "; exit 1; }
    mk_ssh  || { echo >&2 "mk_ssh "; exit 1; }
    do_copy_for_openssh   || { echo >&2 "do_copy_for_openssn "; exit 1; }
    make_key_openssh  || { echo >&2 "make_key_openssh "; exit 1; }
    gen_target_linux_cmd_openssh
}
