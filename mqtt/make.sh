##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
#    Created  :  Sat 30 Nov 2019 01:56:37 PM CST
##
#!/bin/sh
source ../.common

OPENSSL=openssl-1.0.2t

download_package () {
    cd ${BASE}/compressed
    #下载包
    tget  https://www.openssl.org/source/${OPENSSL}.tar.gz
    tgit  https://github.com/eclipse/paho.mqtt.c.git
    tgit  https://github.com/eclipse/mosquitto.git
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
    rm ${OUTPUT_PATH}/${OPENSSL} -rf
    echo "SSL ABOUT"
    CC=${_CC} ./Configure no-asm shared --prefix=${OUTPUT_PATH}/${OPENSSL}

    sed 's/-m64//g'  -i Makefile # 删除-m64 关键字 (arm-gcc 不支持)
    #sudo mv /usr/bin/pod2man /usr/bin/pod2man_bak
    #mv doc/apps /tmp/
    pre_make_ssl
    make clean
    make $MKTHD && make install
}

make_paho_mqtt_c () {
    cd ${BASE}/source/paho.mqtt.c

    make $MKTHD CFLAGS+="-I ${OUTPUT_PATH}/${OPENSSL}/include" \
         LDFLAGS+="-L${OUTPUT_PATH}/${OPENSSL}/lib" \
         CC=${_CC} \
         prefix=${OUTPUT_PATH}/paho.mqtt.c

    # BUG: make install 不符合我们的意愿
    rm ${OUTPUT_PATH}/paho.mqtt.c -rf
    mkdir ${OUTPUT_PATH}/paho.mqtt.c/lib -p
    mkdir ${OUTPUT_PATH}/paho.mqtt.c/bin -p
    mkdir ${OUTPUT_PATH}/paho.mqtt.c/include -p

    cp ${BASE}/source/paho.mqtt.c/build/output/lib*    ${OUTPUT_PATH}/paho.mqtt.c/lib -d -v
    cp ${BASE}/source/paho.mqtt.c/build/output/samples ${OUTPUT_PATH}/paho.mqtt.c/bin -r -v
    cp ${BASE}/source/paho.mqtt.c/build/output/test    ${OUTPUT_PATH}/paho.mqtt.c/bin -r -v
    cp ${BASE}/source/paho.mqtt.c/src/*.h       ${OUTPUT_PATH}/paho.mqtt.c/include    -v

}

make_mosquitto () {
    cd ${BASE}/source/mosquitto

    sed -r -i "/WITH_DOCS:=/ s/.*/WITH_DOCS:=no/"                       config.mk
    sed -r -i "/WITH_SRV:=/ s/.*/WITH_SRV:=no/"                         config.mk
    sed -r -i "/WITH_UUID:=/ s/.*/WITH_UUID:=no/"                       config.mk
    sed -r -i "/WITH_WEBSOCKETS:=/ s/.*/WITH_WEBSOCKETS:=no/"           config.mk
    sed -r -i "/WITH_STRIP:=/ s/.*/WITH_STRIP:=yes/"                    config.mk
    # 不添加 ssl 支持
    sed -r -i "/WITH_TLS:=/ s/.*/WITH_TLS:=no/"                         config.mk
    sed -r -i "/WITH_TLS_PSK:=/ s/.*/WITH_TLS_PSK:=no/"                 config.mk

    # 指定工具链
    sed -i "N;2aCC=${BUILD_HOST}gcc"                                     config.mk
    sed -i "N;2aCXX=${BUILD_HOST}g++"                                    config.mk
    sed -i "N;2aCPP=${BUILD_HOST}g++"                                    config.mk
    sed -i "N;2aCC=${BUILD_HOST}gcc"                                     config.mk
    sed -i "N;2aAR=${BUILD_HOST}ar"                                      config.mk
    sed -i "N;2aLD=${BUILD_HOST}ld"                                      config.mk
    sed -r -i "/STRIP\?=/ s/.*/STRIP\?=${BUILD_HOST}strip/"     config.mk
    # 设置输出路径
    echo "DESTDIR=${OUTPUT_PATH}/mosquitto"                 >>  config.mk
    echo "prefix=\\" >>  config.mk

    make clean
    make $MKTHD && make install

    # 添加 ssl 支持 下编译的 mosquitto
   #sed -r -i "/WITH_TLS:=/ s/.*/WITH_TLS:=yes/"                        config.mk
   #sed -r -i "/WITH_TLS_PSK:=/ s/.*/WITH_TLS_PSK:=yes/"                config.mk
   #make \
   #    CFLAGS+="-I ${OUTPUT_PATH}/${OPENSSL}/include" \
   #    LDFLAGS+="-L${OUTPUT_PATH}/${OPENSSL}/lib -lssl -lcrypto"

   #make \
   #    CFLAGS+="-I ${OUTPUT_PATH}/${OPENSSL}/include" \
   #    LDFLAGS+="-L${OUTPUT_PATH}/${OPENSSL}/lib -lssl -lcrypto" \
   #    install
}

function make_build ()
{
    download_package  || return 1
    tar_package || return 1
    make_ssl || return 1
    make_paho_mqtt_c || return 1
    make_mosquitto || return 1

}

make_build || echo "Err"
