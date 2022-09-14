## 背景：

## 开发板准备

新建以下目录

```bash
mkdir -p /usr/sbin/
mkdir -p /etc/dropbear/
```



拷贝：
从PC机上将以下文件拷贝到目标板Linux系统中


将`dropbear/bin/`和`dropbear/sbin/`下的文件都复制到板上/usr/sbin目录。

```bash
cp bin/* sbin/* /usr/bin
```


生成Key文件

```bash
mkdir  -p /etc/dropbear
cd /etc/dropbear
dropbearkey -t rsa -f dropbear_rsa_host_key
dropbearkey -t dss -f dropbear_dss_host_key
```


执行`/usr/sbin/dropbear -p 22`

此后即可在22端口上登录

如果开发板的 root 用户还没有密码，键入以下命令然输入两次密码来修改，否则其他设备无法连接：

```
passwd root
```



## 开发板设置开机自启动ssh

在启动脚本/etc/init.d/rcS中增加: `/usr/sbin/dropbear -p 22`

此后即可在22端口上登录

其他选项见附录

## 附录：dropbear帮助

```
Dropbear server v2022.82 https://matt.ucc.asn.au/dropbear/dropbear.html
Usage: /usr/sbin/dropbear [options]
-b bannerfile   Display the contents of bannerfile before user login
                (default: none)
-r keyfile      Specify hostkeys (repeatable)
                defaults:
                - dss /etc/dropbear/dropbear_dss_host_key
                - rsa /etc/dropbear/dropbear_rsa_host_key
                - ecdsa /etc/dropbear/dropbear_ecdsa_host_key
                - ed25519 /etc/dropbear/dropbear_ed25519_host_key
-R              Create hostkeys as required
-F              Don't fork into background
-e              Pass on server process environment to child process
-E              Log to stderr rather than syslog
-m              Don't display the motd on login
-w              Disallow root logins
-G              Restrict logins to members of specified group
-s              Disable password logins
-g              Disable password logins for root
-B              Allow blank password logins
-T              Maximum authentication tries (default 10)
-j              Disable local port forwarding
-k              Disable remote port forwarding
-a              Allow connections to forwarded ports from any host
-c command      Force executed command
-p [address:]port
                Listen on specified tcp port (and optionally address),
                up to 10 can be specified
                (default port is 22 if none specified)
-P PidFile      Create pid file PidFile
                (default /var/run/dropbear.pid)
-i              Start for inetd
-W <receive_window_buffer> (default 24576, larger may be faster, max 10MB)
-K <keepalive>  (0 is never, default 0, in seconds)
-I <idle_timeout>  (0 is never, default 0, in seconds)
-V    Version
```
