## 背景：
在一些网络环境下，需要静态IP不够现实，需要使用DHCP进行自动获取IP地址。

udhcpc是一个面向嵌入式系统的非常小的DHCP客户端，字母的缩写微μ- DHCP -客户端client（μDHCPc）。

*前提：在KERNEL中需要将 Packet socket(CONFIG_PACKET)和IP: DHCP support(CONFIG_IP_PNP_DHCP)编译进内核或编译成模块。*

在内核中添加以下选项：
```
Networking  --->
   [*] Networking support  
      Networking options  --->
          <* > Packet socket                 //添加：配置 CONFIG_PACKET
          [ * ]     IP: DHCP support         //添加：配置 CONFIG_IP_PNP_DHCP
          [ * ] Network packet filtering (replaces ipchains)  --->    //添加，子选项可不选：配置 CONFIG_NETFILTER

说明：若没选<* > Packet socket, [ * ] Network packet filtering (replaces ipchains)  --->选项，在执行udhcpc命令时出现如下错误：
~ # udhcpc
udhcpc (v0.9.9-pre) started
udhcpc[208]: udhcpc (v0.9.9-pre) started

FATAL: couldn't listen on socket, Address family not supported by protocol
udhcpc[208]: FATAL: couldn't listen on socket, Address family not supported by protocol
```



## 移植 udhcp

移植udhcp的方法有2种。
**1.在busybox中配置编译：**
Busybox中添加以下选项：
```
Networking Utilities  --->
   udhcp Server/Client  --->
        [] udhcp Server (udhcpd)    //在此不作服务端，故不选。生成udhcpd命令                          
        [*] udhcp Client (udhcpc)       //生成udhcpc命令                               
        [ ] Lease display utility (dumpleases)                        
        [ ]   Log udhcp messages to syslog (instead of stdout)        
        [ ]   Compile udhcp with noisy debugging messages
```
**2.在网上下载源码，进行编译安装即可。(下面介绍这一种)**
使用以下脚本：
```bash
##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
#    Created  :  Tue 24 Dec 2019 04:20:51 PM CST
##
#!/bin/sh
BASE=`pwd`
BUILD_HOST=arm-linux
OUTPUT=${BASE}/install/
make_dirs() {
    cd ${BASE}
    mkdir  compressed  install  source -p
    sudo ls
}
download_package () {
    cd ${BASE}/compressed
    #下载包
    wget  https://udhcp.busybox.net/source/udhcp-0.9.8.tar.gz
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
make_udhcp () {
    cd ${BASE}/source/udhcp*
    sed -i '5, 12{s/COMBINED_BINARY=/#COMBINED_BINARY=/}'  Makefile
    sed -i '130, 135{s/case INIT_SELECTING:/case  INIT_SELECTING:;/}' dhcpc.c
    make   CROSS_COMPILE=${BUILD_HOST}-
}
do_copy () {
    cd ${BASE}/source/udhcp*
    mkdir ${BASE}/install/udhcp -p
    mkdir ${BASE}/install/udhcp/sbin -p
    mkdir ${BASE}/install/udhcp/config -p
    cp ${BASE}/source/udhcp*/udhcpc   ${OUTPUT}/udhcp/sbin -v
    cp ${BASE}/source/udhcp*/udhcpd   ${OUTPUT}/udhcp/sbin -v
    # 默认的配置路径 /usr/share/udhcpc/default.script
    # 写进了代码中 dhcpc.c:62:#define DEFAULT_SCRIPT        "/usr/share/udhcpc/default.script"
    cp ${BASE}/source/udhcp*/samples/simple.script  ${OUTPUT}/udhcp/config/default.script -v
    #cp ${BASE}/source/udhcp*/samples/udhcpd.conf    ${OUTPUT}/udhcp/config/ -v
}

make_dirs
#download_package
tar_package
make_udhcp
do_copy

exit 0

以下内容针对板子
mkdir /usr/share/udhcpc/
cp default.script /usr/share/udhcpc/default.script
chmod +x /usr/share/udhcpc/default.script
```

## 拷贝有关配置文件
**DHCP客户端**
拷贝：simple.script 到板子中的 /usr/share/udhcpc/default.script
```bash
mkdir /usr/share/udhcpc/
cp default.script /usr/share/udhcpc/default.script
chmod +x /usr/share/udhcpc/default.script
```
注:busybox有关路径是在 examples/udhcp，也可以使用 "find . 2>/dev/null | grep" 进行查找
下面提供 default.script 的内容，仅供参考
```bash
#!/bin/sh
# udhcpc script edited by Tim Riker <Tim@Rikers.org>
[ -z "$1" ] && echo "Error: should be called from udhcpc" && exit 1
RESOLV_CONF="/etc/resolv.conf"
[ -n "$broadcast" ] && BROADCAST="broadcast $broadcast"
[ -n "$subnet" ] && NETMASK="netmask $subnet"
case "$1" in
        deconfig)
                /sbin/ifconfig $interface 0.0.0.0
                ;;
        renew|bound)
                /sbin/ifconfig $interface $ip $BROADCAST $NETMASK
                if [ -n "$router" ] ; then
                        echo "deleting routers"
                        while route del default gw 0.0.0.0 dev $interface ; do
                                :
                        done
                        for i in $router ; do
                                route add default gw $i dev $interface
                        done
                fi
                echo -n > $RESOLV_CONF
                [ -n "$domain" ] && echo search $domain >> $RESOLV_CONF
                for i in $dns ; do
                        echo adding dns $i
                        echo nameserver $i >> $RESOLV_CONF
                done
                ;;
esac
exit 0
```
**DHCP服务器端**
vi /etc/udhcpd.conf
```bash
# The start and end of the IP lease block
start       192.168.1.20    #default: 192.168.0.20   客户端分配的地址范围
end        192.168.1.25    #default: 192.168.0.254
# The interface that udhcpd will use
interface   wlan0       #default: eth 0 #目标板子上的无线网卡wlan0
#Examles
opt dns 222.201.130.30 222.201.130.33   #dns服务器
option subnet 255.255.255.0
opt router 192.168.1.10                    #wlan的 ip地址,做为网关地址
#opt    wins    192.168.10.10              #注释掉
option dns 192.168.1.10                    # appened to above DNS servers  for a total of 3
option domain local
option lease   864000      # 10 days of seconds
```

## 测试
重启开发板，执行udhcpc就可自动获取IP地址了，以下是执行udhcpc的输出信息：

```bash
 udhcpc -b -i eht0 -q

udhcpc (v0.9.9-pre) started
udhcpc[228]: udhcpc (v0.9.9-pre) started
Sending discover...
udhcpc[228]: Sending discover...
Sending select for 192.168.1.109...
udhcpc[228]: Sending select for 192.168.1.109...
Lease of 192.168.1.109 obtained, lease time 86400
udhcpc[228]: Lease of 192.168.1.109 obtained, lease time 86400
deleting routers
route: SIOC[ADD|DEL]RT: No such process
adding dns 192.168.0.1


~ # ping www.baidu.com
PING www.a.shifen.com (220.181.38.4): 56 data bytes
64 bytes from 220.181.38.4: icmp_seq=0 ttl=52 time=1219.0 ms
```

