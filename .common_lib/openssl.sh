export OPENSSL=openssl-1.0.2t

## for others
OPENSSL_FILE_NAME=${OPENSSL}.tar.gz
OPENSSL_ARCH_PATH=$ROOT_DIR/openssl/compressed/${OPENSSL_FILE_NAME}

### OPENSSL
function get_ssl () {
    if [ -f "$OPENSSL_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $OPENSSL_ARCH_PATH $ARCHIVE_PATH/$OPENSSL_FILE_NAME
        return
    else
        tget  https://www.openssl.org/source/${OPENSSL}.tar.gz
    fi
}

# 删除不需要的Makefile的doc规则
# 这部分规则容易引起Makefile死循环
function pre_make_ssl () {
    bash <<EOF
    cd ${BASE}/source/${OPENSSL}
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
    pre_make_ssl || return 1
    bash <<EOF

    cd ${BASE}/source/${OPENSSL}
    echo "SSL ABOUT"
    CC=${_CC} ./config no-asm shared --prefix=${OUTPUT_PATH}/${OPENSSL}

    sed 's/-m64//g'  -i Makefile # 删除-m64 关键字 (arm-gcc 不支持)
    #sudo mv /usr/bin/pod2man /usr/bin/pod2man_bak
    #mv doc/apps /tmp/
    make $MKTHD && make install
EOF
}

function make_ssl () {
    get_ssl
    tar_package       || return 1
    mk_ssl || return 1
}

