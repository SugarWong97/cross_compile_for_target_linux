#CONFIG_OPENSSH_VERSION=6.6p1
export CONFIG_OPENSSH_VERSION=9.1p1

OPENSSH=openssh
OPENSSH_VERSION=openssh-${CONFIG_OPENSSH_VERSION}


export OPENSSH_OUTPUT_PATH=${OUTPUT_PATH}/${OPENSSH}

export FIN_INSTALL_OPENSSH=/usr/local

#下载包
download_ssh () {
    get_zlib
    tget  https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz
    tget  http://mirrors.mit.edu/pub/OpenBSD/OpenSSH/portable/${OPENSSH_VERSION}.tar.gz
}

## ssh 要求不能修改 prefix
do_copy_for_openssh () {
    cd ${CODE_PATH}/${OPENSSH_VERSION}
    mkdir ${OPENSSH_OUTPUT_PATH}/bin -p
    mkdir ${OPENSSH_OUTPUT_PATH}/sbin -p
    mkdir ${OPENSSH_OUTPUT_PATH}/etc -p
    mkdir ${OPENSSH_OUTPUT_PATH}/libexec -p

    cp -v scp  sftp  ssh  ssh-add  ssh-agent \
        ssh-keygen  ssh-keyscan         ${OPENSSH_OUTPUT_PATH}/bin
    cp -v moduli ssh_config sshd_config ${OPENSSH_OUTPUT_PATH}/etc
    cp -v sftp-server  ssh-keysign      ${OPENSSH_OUTPUT_PATH}/libexec
    cp -v sshd                          ${OPENSSH_OUTPUT_PATH}/sbin

    #scp  sftp  ssh  ssh-add  ssh-agent  ssh-keygen  ssh-keyscan  拷贝到目标板/usr/local/bin
    #moduli ssh_config sshd_config拷贝到目标板 /usr/local/etc
    #sftp-server  ssh-keysign 拷贝到目标板 /usr/local/libexec
    #sshd 拷贝到目标板 /usr/local/sbin/
    echo "Copy all dirs under $FIN_INSTALL_OPENSSH" > ${OPENSSH_OUTPUT_PATH}/install_path
    # 拷贝其他脚本、配置
    mkdir -p ${OUTPUT_PATH}/others
    rm ${OUTPUT_PATH}/others/* -rf
    cp ${BASE}/meta/*  ${OUTPUT_PATH}//others
}

make_key_openssh () {
    cd ${CODE_PATH}/${OPENSSH_VERSION}
    ssh-keygen -t rsa       -f  ssh_host_key -N         ""
    ssh-keygen -t rsa       -f  ssh_host_rsa_key -N     ""
    ssh-keygen -t dsa       -f  ssh_host_dsa_key -N     ""
    ssh-keygen -t ecdsa     -f  ssh_host_ecdsa_key -N   ""
    ssh-keygen -t ed25519   -f  ssh_host_ed25519_key -N ""

    #将生成的 ssh_host_*_key这4个文件copy到目标板的 $FIN_INSTALL_OPENSSH/etc/目录下
    cp ssh_host*key ${OPENSSH_OUTPUT_PATH}/etc
}

mk_ssh () {

    # 如果ssl是so库，在后续的很多时候都会需要考虑环境变量的问题
    echo "ALLOW STATIC LINK ONLY"
    rm -v -rf ${OPENSSH_OUTPUT_PATH}/lib/*.so*

    bash <<EOF
    cd ${CODE_PATH}/${OPENSSH_VERSION}
    ./configure \
    --host=${BUILD_HOST} \
    --build=i386 \
    --prefix=${FIN_INSTALL_OPENSSH} \
    --with-libs --with-zlib=${ZLIB_OUTPUT_PATH} \
    --with-ssl-dir=${OPENSSL_OUTPUT_PATH} \
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

cp -rfv  ${OPENSSH}/*          ${FIN_INSTALL_OPENSSH}/
#cp -rfv  ${OPENSSL}/lib/*.so*  ${FIN_INSTALL_OPENSSH}/lib/
#cp -rfv  ${ZLIB}/lib/*.so*     ${FIN_INSTALL_OPENSSH}/lib/

cp /etc/passwd  /etc/passwd_bak
echo "sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin" >> /etc/passwd

EOF
) > ${OUTPUT_PATH}/openssh.install
    chmod +x ${OUTPUT_PATH}/openssh.install
}

make_ssh ()
{
    download_ssh
    tar_package
    make_zlib || { echo >&2 "make_zlib "; exit 1; }
    #make_ssl  || { echo >&2 "make_ssl "; exit 1; }
    mk_ssh  || { echo >&2 "mk_ssh "; exit 1; }
    do_copy_for_openssh   || { echo >&2 "do_copy_for_openssn "; exit 1; }
    make_key_openssh  || { echo >&2 "make_key_openssh "; exit 1; }
    gen_target_linux_cmd_openssh
}
