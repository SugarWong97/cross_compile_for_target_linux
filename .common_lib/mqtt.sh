
download_mqtt () {
    get_ssl
    tgit  https://github.com/eclipse/paho.mqtt.c.git
    tgit  https://github.com/eclipse/mosquitto.git
}

mk_paho_mqtt_c () {
    make_ssl || return 1
    bash <<EOF
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

    cp -d -v ${BASE}/source/paho.mqtt.c/build/output/lib*    ${OUTPUT_PATH}/paho.mqtt.c/lib
    cp -r -v ${BASE}/source/paho.mqtt.c/build/output/samples ${OUTPUT_PATH}/paho.mqtt.c/bin
    cp -r -v ${BASE}/source/paho.mqtt.c/build/output/test    ${OUTPUT_PATH}/paho.mqtt.c/bin
    cp    -v ${BASE}/source/paho.mqtt.c/src/*.h              ${OUTPUT_PATH}/paho.mqtt.c/include
EOF
}

mk_mosquitto () {
    bash <<EOF
    cd ${BASE}/source/mosquitto

    # 杂项
    sed -r -i "/WITH_DOCS:=/ s/.*/WITH_DOCS:=no/"                   config.mk
    sed -r -i "/WITH_SRV:=/ s/.*/WITH_SRV:=no/"                     config.mk
    sed -r -i "/WITH_UUID:=/ s/.*/WITH_UUID:=no/"                   config.mk
    sed -r -i "/WITH_WEBSOCKETS:=/ s/.*/WITH_WEBSOCKETS:=no/"       config.mk
    sed -r -i "/WITH_STRIP:=/ s/.*/WITH_STRIP:=yes/"                config.mk
    # 不添加 ssl 支持
    sed -r -i "/WITH_TLS:=/ s/.*/WITH_TLS:=no/"                     config.mk
    sed -r -i "/WITH_TLS_PSK:=/ s/.*/WITH_TLS_PSK:=no/"             config.mk
    # 不添加 cjson支持
    sed -r -i "/WITH_CJSON:=/ s/.*/WITH_CJSON:=no/"                 config.mk

    # 指定工具链
    sed -i "N;2aCC=${_CC} "                             config.mk
    sed -i "N;2aCXX=${_CPP} "                           config.mk
    sed -i "N;2aCPP=${_CPP} "                           config.mk
    sed -i "N;2aAR=${_AR} "                             config.mk
    sed -i "N;2aLD=${_LD} "                             config.mk
    sed -r -i "/STRIP\?=/ s/.*/STRIP\?=${_STRIP}/"     config.mk
    # 设置输出路径
    echo "DESTDIR=${OUTPUT_PATH}/mosquitto"        >>  config.mk
    echo 'prefix=\\' >>  config.mk
    make clean

    make $MKTHD && make install

    # 添加 ssl 支持 下编译的 mosquitto
    #sed -r -i "/WITH_TLS_PSK:=/ s/.*/WITH_TLS_PSK:=yes/"                config.mk
    #sed -r -i "/WITH_TLS:=/ s/.*/WITH_TLS:=yes/"                        config.mk
    #make \
    #    CFLAGS+="-I ${OUTPUT_PATH}/${OPENSSL}/include" \
    #    LDFLAGS+="-L${OUTPUT_PATH}/${OPENSSL}/lib -lssl -lcrypto"

    #make \
    #    CFLAGS+="-I ${OUTPUT_PATH}/${OPENSSL}/include" \
    #    LDFLAGS+="-L${OUTPUT_PATH}/${OPENSSL}/lib -lssl -lcrypto" \
    #    install
    #
EOF
}

function make_mosquitto ()
{
    download_mqtt  || return 1
    tar_package || return 1
    mk_paho_mqtt_c || return 1
    mk_mosquitto || return 1
}

