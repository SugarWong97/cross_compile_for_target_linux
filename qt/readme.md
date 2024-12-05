## 背景
QT 在 开发中很常见。

平台        ： Ubuntu 16.04

[QT ](http://mirrors.ustc.edu.cn/qtproject/archive/qt/)         ：[5.9.8](http://mirrors.ustc.edu.cn/qtproject/archive/qt/5.9/5.9.8/single/qt-everywhere-opensource-src-5.9.8.tar.xz)

[tslib](https://www.cnblogs.com/schips/p/ https://github.com/libts/tslib/releases/tag/1.4)         ： [1.4](https://github.com/libts/tslib/releases/download/1.4/tslib-1.4.tar.bz2 )
arm-gcc     ： 4.8.1 （ > 4.8 ）


## 编译

```
./make.sh
```

## 部署开发板的环境

将install下的2个目录 拷贝到开发板的文件系统中，建议是放在 /usr 。（下面以/usr目录为例）


在`/etc/profile` 中加入`install/qt.profile`：


## QT-creator添加新的arm-gcc

***安装QT（[Ubuntu 安装 QtCreator (version : Qt 5.9.8)](https://www.cnblogs.com/schips/p/12029921.html)）***

***注意：下文图示中，有可能在实际操作过程会遇到红色感叹号，其实是正常的。***

### **QT配置：**

#### **添加QMAKE：**

“Tools”-“Options”-“Build & Run”-“Qt Versions”，点击Add添加qmake路径

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212173712066-583650743.png)

 

点击 Apply。

 

#### **添加Compilers：**

**“Tools”-“Options”-“kits” - "Compilers"
**

选择 Add - > GCC 。依次选择 C/C++ ，并添加板子对应的arm-gcc/g++

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174943863-938290067.png)


 点击 Apply。


#### **添加debugers：（可选项）**

**“Tools”-“Options”-“kits” - "\**debugers\**"** 

添加Debugers 与 Compilers 同理，不再赘述，配置以后点击 Apply

 

#### **添加Devices：**

**“Tools”-“Options”-“Devices”** 

注意：先将开发板与电脑连接到同一局域网，并查看开发板 IP 地址。
在点取菜单栏的"Tools->Options"，选取 Devices 选项。点击 Add 添加。选取第一个"Generic Linux Devive"选项，点击"Start Wizard"选取。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212173813115-881946723.png)

 
给开发板取个名字，再填上开发板的 IP 地址和用户名，密码，点击 Next。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174012063-460564737.png)


点击 Finish 开始连接开发板，当出现"Device test finished successfully"字样说明连接成功。点击 Closed。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174035294-1070775587.png)

 

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174120679-1998308129.png)


点击"Create new…"， Key algotithm 选取 RSA， Key size 选取 1024，点击"Generate And Save Key Pair"。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174225033-1565490743.png)


点击"Do Not Encrypt Key File"。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174254887-1093178008.png)


点击"Deploy public Key"，打开 qtc_ip.pub，显示"Deployment finished successfully"则表示设备配置成功。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212174413386-1424765712.png)

 点击 Apply 

 

#### 添加工具集：

**“Tools”-“Options”-“Kits” 
**

注意： 不同的QT版本这个选项的位置不同，有些在 “Tools”-“Options”-“Build & Run”这里 。

点击Add，选择上文配置的，具体如下： 

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212175320777-1823826370.png)

 
 QT编译以后，提示以下错误：（此项只影响能否在板子上显示正在开发中的程序）

```
SFTP initialization failed: Server could not start SFTP subsystem.
```

只需要找到 板子 sshd 对应的配置文件sshd_config，设置好正确的sftp-server路径即可

```
Subsystem sftp /usr/local/libexec/sftp-server 
```

## 测试

新建QT工程，勾选新添加的 Kits，之后编译运行即可。

![img](https://img2018.cnblogs.com/i-beta/1281523/201912/1281523-20191212175806788-1080079244.png)


正确配置好以后，点击运行即可在开发板连接的屏幕上看到结果了。
