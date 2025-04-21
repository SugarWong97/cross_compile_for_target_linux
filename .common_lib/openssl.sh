export OPENSSL=openssl
export CONFIG_OPENSSL=1.0.2t
export OPENSSL_VERSION=openssl-$CONFIG_OPENSSL
export OPENSSL_OUTPUT_PATH=${OUTPUT_PATH}/${OPENSSL}
export OPENSSL_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${OPENSSL}

## for others
export OPENSSL_FILE_NAME=${OPENSSL_VERSION}.tar.gz
export OPENSSL_ARCH_PATH=$ROOT_DIR/openssl/compressed/${OPENSSL_FILE_NAME}

function _sync_export_var_openssl()
{
    export OPENSSL_FILE_NAME=${OPENSSL_VERSION}.tar.gz
    export OPENSSL_ARCH_PATH=$ROOT_DIR/openssl/compressed/${OPENSSL_FILE_NAME}
}

### OPENSSL
function get_ssl () {
    _sync_export_var_openssl
    tget_package_from_arch  $OPENSSL_ARCH_PATH $ARCHIVE_PATH/$OPENSSL_FILE_NAME https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz
}
function get_openssl () {
    get_ssl
}

# 删除不需要的Makefile的doc规则
# 这部分规则容易引起Makefile死循环
function pre_make_ssl () {
    bash <<EOF
    cd ${CODE_PATH}/${OPENSSL_VERSION}
    startLine=\`sed -n '/install_html_docs\:/=' Makefile\`
    echo \$startLine
    for startline in \$startLine # 避免多行结果
    do
        endLine=\`expr \$startline + 999\`
        sed -i \$startline','\$endLine'd' Makefile
        echo "install_html_docs:" >> Makefile
        echo -e "\t@echo skip by Schips" >> Makefile
        echo "install_docs:" >> Makefile
        echo -e "\t@echo skip by Schips" >> Makefile
        echo "# DO NOT DELETE THIS LINE -- make depend depends on it." >> Makefile
        break
    done
EOF
}
function mk_ssl () {
    local build_for_host="$1" # say anything for host

    local build_for_host_part_arg=""
    local output_dir="${OPENSSL_OUTPUT_PATH}"

    pre_make_ssl || return 1

    if [  "$build_for_host" != '' ];then
        build_for_host_part_arg="CC=gcc"
        output_dir="$OPENSSL_OUTPUT_PATH_HOST"
    else
        build_for_host_part_arg="CC=${_CC}"
        output_dir="$OPENSSL_OUTPUT_PATH"
    fi

    cd ${CODE_PATH}/${OPENSSL_VERSION}
    cat <<EOF > $tmp_config
    ${build_for_host_part_arg} ./config no-asm shared --prefix=${output_dir}
    make clean

    sed 's/-m64//g'  -i Makefile # 删除-m64 关键字 (arm-gcc 不一定支持)
    make $MKTHD && make install $MKTHD
EOF
    bash $tmp_config
}

function make_ssl () {
    _sync_export_var_openssl
    get_ssl
    tar_package       || return 1
    mk_ssl || return 1
}

function make_ssl_host () {
    _sync_export_var_openssl
    get_ssl
    tar_package       || return 1
    mk_ssl host || return 1
}

