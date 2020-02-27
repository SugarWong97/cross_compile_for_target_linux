## 前言
我们在这里做2件事情：
1）编译 `paho.mqtt`、`mosquitto` 2个开源项目的c版本库（mosquitto库没有用上）
2）编译好 依赖 `paho.mqtt`的库编写例程 + mosquitto 服务器。

> host平台　　 ：Ubuntu 16.04
> arm 平台    ： s5p6818
> ssl         ： [openssl-1.0.2t](https://www.openssl.org/source/openssl-1.0.2t.tar.gz)
> MQTT-client :  [paho.mqtt.c](https://github.com/eclipse/paho.mqtt.c.git)

现在我们就来进行MQTT客户端的移植。
> MQTT服务器(Broker)在很多 云服务器中自带了，没有特殊需求是不做移植的；而且就算做了 Broker 移植，也相对简单。

## 主机准备
使用以下脚本即可。
> 之前[《搭建MQTT通信环境，并抓包测试》](https://www.cnblogs.com/schips/p/12258386.html)   没有介绍在：Linux下 编译运行 mosquitto 服务器，所以在下面的脚本中也有介绍，具体参考：`make_mosquitto () `


```bash
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
#    Created  :  Sat 30 Nov 2019 01:56:37 PM CST
##
#!/bin/sh
BUILD_HOST=arm-linux-
ARM_GCC=${BUILD_HOST}gcc
ARM_CPP=${BUILD_HOST}g++
BASE=`pwd`
OUTPUT_PATH=${BASE}/install

OPENSSL=openssl-1.0.2t

make_dirs () {
    #为了方便管理，创建有关的目录
    cd ${BASE} && mkdir compressed install source -p
}

tget () { #try wget
    filename=`basename $1`
    echo "Downloading [${filename}]..."
    if [ ! -f ${filename} ];then
        wget $1
    fi

    echo "[OK] Downloaded [${filename}] "
}

tgit () { #try git and tar
    filename=`basename $1 | sed 's/.git//g'`

    echo "Clone [${filename}]..."
    if [ ! -f ${filename}.tgz ];then
        git clone $1
        rm ${filename}/.git* -rf
        echo "Making a tar file."
        tar -zcf ${filename}.tgz ${filename}
        rm ${filename} -rf
    fi

    echo "[OK] Cloned [${filename}] "
}

download_package () {
    cd ${BASE}/compressed
    #下载包
    tget  https://www.openssl.org/source/${OPENSSL}.tar.gz
    tgit  https://github.com/eclipse/paho.mqtt.c.git
    tgit  https://github.com/eclipse/mosquitto.git
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
    CC=${ARM_GCC} ./Configure no-asm shared --prefix=${OUTPUT_PATH}/${OPENSSL}

    sed 's/-m64//g'  -i Makefile # 删除-m64 关键字 (arm-gcc 不支持)
    #sudo mv /usr/bin/pod2man /usr/bin/pod2man_bak
    #mv doc/apps /tmp/
    pre_make_ssl
    make && make install
}

make_paho_mqtt_c () {
    cd ${BASE}/source/paho.mqtt.c

    make CFLAGS+="-I ${OUTPUT_PATH}/${OPENSSL}/include" \
         LDFLAGS+="-L${OUTPUT_PATH}/${OPENSSL}/lib" \
         CC=${ARM_GCC} \
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

    make  && make install

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

make_dirs
download_package
tar_package
make_ssl
make_paho_mqtt_c
make_mosquitto
exit $?

```
## 目标板准备
将install 下运行库拷贝到板子上，添加到路径即可。

## 测试
使用以下的测试程序，服务器根据自己的需求进行指定
> 有关的例程在 ${paho_mqtt_c}/src/samples 可以找到。

```cpp
/*
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#
#    File Name:  main.cpp
#    Created  :  Sun 09 Feb 2020 10:14:44 AM CST
*/

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <MQTTClient.h>   /* MQTT头文件的位置  */
#include <sys/time.h>
#include <termios.h>


#define ADDRESS     "tcp://localhost:1883"   /* 指定服务器的ip地址 这里使用本机的 mosquitto 进行测试使用  */
#define CLIENTID    "ExampleClientPub"
#define TOPIC       "MQTT Examples"
#define PAYLOAD     "Hello World!"
#define QOS         1
#define TIMEOUT     10000L

using namespace std;
int main(int argc, char* argv[])
{
    MQTTClient client;
    MQTTClient_connectOptions conn_opts = MQTTClient_connectOptions_initializer;
    MQTTClient_message pubmsg = MQTTClient_message_initializer;
    MQTTClient_deliveryToken token;

    MQTTClient_message *receivemsg = NULL ;
    char* topicName_rev = NULL;
    int   topicLen_rev;

    int rc;
    int i;

    MQTTClient_create(&client, ADDRESS, CLIENTID,
    MQTTCLIENT_PERSISTENCE_NONE, NULL);
    conn_opts.keepAliveInterval = 60;
    conn_opts.cleansession = 1;

    if ((rc = MQTTClient_connect(client, &conn_opts)) != MQTTCLIENT_SUCCESS)
    {
        printf("Failed to connect, return code %d\n", rc);
        exit(-1);
    }
    pubmsg.payload = (void *)PAYLOAD;
    pubmsg.payloadlen = strlen(PAYLOAD);
    pubmsg.qos = QOS;
    pubmsg.retained = 0;
    MQTTClient_subscribe(client, "test", 1);                        /* 订阅一个客户端 的一个话题*/
    usleep(10000);
    MQTTClient_publishMessage(client, TOPIC, &pubmsg, &token); /* 发送消息 */
    printf("Waiting for up to %d seconds for publication of %s\n"
            "on topic %s for client with ClientID: %s\n",
            (int)(TIMEOUT/1000), PAYLOAD, TOPIC, CLIENTID);
    rc = MQTTClient_waitForCompletion(client, token, TIMEOUT);
    printf("Message with delivery token %d delivered\n", token);
    for(;;)
    {
               if(MQTTClient_isConnected(client) == true)   /* 检测连接状态 */
               {
                   printf("alive \n");
               }else{
                   printf(" no alive \n");
                   break;
               }
            rc = MQTTClient_receive(client,&topicName_rev, &topicLen_rev, &receivemsg,5000); /* 接收消息 */
               if(rc == MQTTCLIENT_SUCCESS)
               {
                printf("Message REv  %d delivered\n", rc);
                printf("topicName: %s  topicName_LEN: %d \n", topicName_rev,topicLen_rev);
                if(topicName_rev != NULL)                          /* 滤掉心跳包 */
                {
                    printf("topicName: ");
                    for(i=0;i<topicLen_rev;i++)
                    {
                        printf(" %c ", topicName_rev[i]);
                    }
                    printf("\n");
                    printf("Data: %s  len:%d msgid: %d \n",(char *)receivemsg->payload,receivemsg->payloadlen,receivemsg->msgid);
                     if(strcmp((char *)receivemsg->payload,"ESC") == 0)
                    {
                        printf("ESC \n");
                        break;
                    }
                }
            }

            usleep(10000);
            usleep(100000);
    }
    MQTTClient_disconnect(client, 10000);
    MQTTClient_destroy(&client);
    return rc;
}

```
编译命令
```
arm-linux-g++ -I ./paho.mqtt.c/src -L ./paho.mqtt.c/build/output/ -lpaho-mqtt3c main.cpp  -o client
```

