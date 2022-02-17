##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Mon 28 Setp 2020 14:29:31 PM CST

##
#!/bin/sh

source ../.common
OPENSSL=openssl-1.0.2t

download_iperf () {
    get_zlib
    tget  https://www.openssl.org/source/${OPENSSL}.tar.gz
    #下载包
    ## http://downloads.es.net/pub/iperf/
    tget    https://downloads.es.net/pub/iperf/iperf-3.6.tar.gz
}

set_compile_env_for_arm () {
	export CC=${_CC}
	export AR=${_AR}
	export LD=${_LD}
	export RANLIB=${_RANLIB}
	export STRIP=${_STRIP}
}

make_iperf_host () {
    cd ${BASE}/source/iperf*
    ./configure --prefix=${OUTPUT_PATH}/iperf_host
    make clean
    make $MKTHD && make install
}

# 有些平台的ssl是需要移植的
make_iperf_target () {
    support_ssl="yes"
    if [ "$support_ssl" = "yes" ]; then
        make_zlib
        make_ssl
        bash <<EOF
        cd ${BASE}/source/iperf*
        ./configure --host=${BUILD_HOST} --prefix=${OUTPUT_PATH}/iperf_target \
            --with-openssl=${OUTPUT_PATH}/${OPENSSL}
        make clean
        make $MKTHD && make install
EOF
    else
        bash <<EOF
        cd ${BASE}/source/iperf*
        ./configure --host=${BUILD_HOST} --prefix=${OUTPUT_PATH}/iperf_target
        make clean
        make $MKTHD && make install
EOF
    fi
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

function make_build ()
{
    download_iperf  || return 1
    tar_package || return 1


    make_iperf_host  || return 1
    set_compile_env_for_arm
    make_iperf_target  || return 1
}

make_build || echo "Err"
