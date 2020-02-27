## 背景：
公司用的产品主板支持wifi接口，为了加强产品的功能，做wifi的底层支持。
> 有关知识点：[浅谈 Linux 内核无线子系统](https://www.cnblogs.com/rain-blog/p/linux-wireless.html)             

## 概览
主要的流程如下：
> 内核配置 + 有关驱动的移植 + 软件的移植 + 软件的配置


## 内核配置
```Memuconfig
# WIFI驱动
Networking support
        <*>   RF switch subsystem support  --->
                [*]   Power off on suspend (NEW)
                <*>   Generic rfkill regulator driver
                （防止使用wpa_supplicant会出现rfkill: Cannot open RFKILL  control device错误。）

        -*-   Wireless  --->
        <*>   cfg80211 - wireless configuration API
        [*]     nl80211 testmode command
        [*]     enable powersave by default
        [*]     cfg80211 wireless extensions compatibility
        <*>   Generic IEEE 802.11 Networking Stack  (mac80211)
```

```Memuconfig
# WIFI作为AP热点的额外配置
Device Drivers  --->
   [*] Network device support  --->
        [*] Wireless LAN  --->
                        <*>    IEEE 802.11 for Host AP  (Prism2/2.5/3 and WEP/TKIP/CCMP)
                        [*]     Support downloading firmware  images with Host AP driver
                        [*]       Support for non-volatile  firmware download
```

## wpa软件移植
根据有关资料，移植wifi有关驱动各工具如下：

| 软件包         | 说明                                                         |
| :------------- | ---------------------------------------------------------- |
| WirelessTools  | 只支持WEP认证方式                                            |
| wpa_supplicant | 支持WPA认证方式                                              |
| hostapd        | hostapd能够使得无线网卡切换为master模式，模拟AP(通常可以认为是路由器)功能软AP(Soft AP） |
| dhcpcd         | dhcpcd是DHCP client的实现，可以作为后台守护进程运行。        |


**一个脚本编译 wpa_supplicant：**

```BASH
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
#    Created  :  Tue 10 Dec 2019 05:42:56 PM CST
#!/bin/sh
BUILD_HOST=arm-linux
ARM_GCC=${BUILD_HOST}-gcc
BASE=`pwd`
OUTPUT_PATH=${BASE}/install
OPENSSL=openssl-1.0.2t
WPA_SUPPLICANT=wpa_supplicant-0.7.3

make_dirs() {
    cd ${BASE}
    mkdir  compressed  install  source -p
}

tget () { #try wget
    filename=`basename $1`
    echo "Downloading [${filename}]..."
    if [ ! -f ${filename} ];then
        wget $1
    fi

    echo "[OK] Downloaded [${filename}] "
}

download_package () {
    cd ${BASE}/compressed
    #下载包
    tget https://www.openssl.org/source/${OPENSSL}.tar.gz
    tget http://w1.fi/releases/${WPA_SUPPLICANT}.tar.gz
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
    startLine=`sed -n '/install_html_docs\:/=' Makefile |  awk -F\b '{ print $1 }'`
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
        echo "# DO NOT DELETE THIS LINE -- make depend  depends on it." >> Makefile
        break
    done
}

make_openssl () {
    cd ${BASE}/source/${OPENSSL}
    echo "SSL ABOUT"
        ./Configure --prefix=${OUTPUT_PATH}/${OPENSSL}  os/compiler:${ARM_GCC}
    pre_make_ssl
    make && make install
}

make_wpa () {
    cd ${BASE}/source/wpa*/wpa*
    cp defconfig .config
    echo "CC=${ARM_GCC} -L${OUTPUT_PATH}/${OPENSSL}/lib"  >> .config
    echo "CFLAGS += -I${OUTPUT_PATH}/${OPENSSL}/include"  >> .config
    echo "LIBS += -L${OUTPUT_PATH}/${OPENSSL}/lib" >>  .config
    make && make install DESTDIR=${BASE}/install/wpa_supplicant/
    cp ${BASE}/source/wpa*/wpa*/examples/wpa-psk-tkip.conf ${BASE}/install/wpa_supplicant/wpa.conf
    # 在ctrl_interface 当前行下插入 update_config=1
    sed -i '/ctrl_interface/aupdate_config=1' ${BASE}/install/wpa_supplicant/wpa.conf
}

make_dirs
download_package
tar_package
make_openssl
make_wpa

```
生成结果的目录结构如下：
> $ tree install/wpa_supplicant
> install/wpa_supplicant
> ├── usr
> │   └── local
> │       └── sbin
> │           ├── wpa_cli
> │           ├── wpa_passphrase
> │           └── wpa_supplicant
> └── wpa.conf

将install中wpa_supplicant/usr/local/sbin下的可执行程序拷贝到板子上
拷贝install中的wpa_supplicant/wpa.conf 一并拷出。

## wpa软件配置
**运行wifi服务：**
`nohup wpa_supplicant -D nl80211 -i wlan0 -c $CONFIG  > log &`
> -c 用于指定配置

**使用wpa_supplicant工具主要有2种途径：**
1.基于配置文件的使用
> 在运行 wpa_supplicant 时指定` -c 配置文件名`
> 这种使用方法一般只针对连接知道ssid与psk的网络连接

2.wpa_cli 交互式控制
> wpa_cli 是wpa_supplicant 的交互客户端，可完成`通过配置文件`方法做不到的复杂操作。
> 注意，wpa_cli 需要在 wpa_supplicant 已经执行的情况下才有效（最好是是使用`nohup .. & > log`这样的方式运行）

* 扫描网络并获取结果：
```BASH
# 扫描网络
wpa_cli -i wlan0 scan 
# 获取当前结果
wpa_cli -i wlan0 scan_result
```
* 添加网络连接：
```BASH
NID=`wpa_cli -i wlan0 add_network`
SSID=test_wifi_name
wpa_cli -i wlan0 set_network $NID ssid '$SSID'
# 无密码时的连接
wpa_cli -i wlan0 set_network $NID key_mgmt NONE
# 有密码时的连接
wpa_cli -i wlan0 set_network $NID psk '$PASSWD"'
# 设置网络属性（默认即可）
wpa_cli -i wlan0 set_network $NID priority 2
wpa_cli -i wlan0 set_network $NID scan_ssid 1

# 启动网络
wpa_cli -i wlan0 enable_network $NID
wpa_cli -i wlan0 select_network $NID
```
* 获取当前网络状态
```wpa_cli -i wlan0 status```


* 断开网络连接
```BASH
wpa_cli -i wlan0 disable_network $NID
wpa_cli -i wlan0 remove_network $NID 
```

* 保存网络配置到当前使用的配置文件中（一般用于未连接状态时）
```wpa_cli -i wlan0 save_config```

> 一般，本人会使用交互式的命令进行网络扫描，将结果过滤到文件中再根据前端调用发过来的SSID与PSK，生成一份临时的配置文件以后
> 最后重启 wpa_supplicant 时，指定好 临时的配置文件，再获取> 当前网络的状态，以实现wifi的后续使用（分配IP）


连接wifi的环境已经搭建好了。

有关dhcp自动分配IP的部分请参考[《arm linux 移植 udhcp 与 使用》](https://www.cnblogs.com/schips/p/12132115.html)
