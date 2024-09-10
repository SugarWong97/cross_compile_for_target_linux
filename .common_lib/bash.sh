
export BASH=bash
export CONFIG_BASH_VERSION=4.3
export BASH_VERSION=${BASH}-${CONFIG_BASH_VERSION}
export BASH_OUTPUT_PATH=${OUTPUT_PATH}/bash

function download_bash () {
    #tget    https://ftp.gnu.org/gnu/bash/bash-5.1.8.tar.gz
    tget    https://ftp.gnu.org/gnu/bash/bash-${CONFIG_BASH_VERSION}.tar.gz
}

function mk_bash () {
    bash <<EOF

    cd ${CODE_PATH}/$BASH_VERSION

    ./configure CC=${_CC} --prefix=${BASH_OUTPUT_PATH} \
        --host=arm-linux \
        --target=${BUILD_HOST} \
        --enable-history \
        --without-bash-malloc  \
        --cache-file=arm-linux.cache
    make clean
    make $MKTHD && make install
EOF
}

function echo_bash_help ()
{
    cat <<EOF
ok
-------------安装-------------
1. 将 install/bin中的 bash 文件复制至开发板 /bin 中
2. 修改 开发板中 /bin/bash 权限 : "chmod +x /bin/bash"
3. 执行 "val1=15; val2=1; and=\$[ \$val1 & \$val2 ]; echo \$and"，理论上ash会有错误产生
4. 输入bash，再执行上面的命令，预期正确的打印

-------------默认-------------
1. 备份原有的sh: "cd /bin; mv sh sh.old"
2. 修改: "ln -s bash sh"
EOF
}

function make_bash ()
{
    export BASH_VERSION=${BASH}-${CONFIG_BASH_VERSION}
    download_bash  || return 1
    tar_package || return 1

    mk_bash  || return 1
    echo_bash_help
}

