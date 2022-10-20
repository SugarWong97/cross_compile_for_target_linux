## 背景
Go是一门全新的静态类型开发语言，具有`自动垃圾回收`，`丰富的内置类型`,`函数多返回值`，`错误处理`，`匿名函数`,`并发编程`，`反射`等特性。

从Go1.4之后Go语言的编译器完全由Go语言编写，所以为了从源代码编译Go需要先编译一个1.4版本的Go版本。


所以，搭建go语言开发环境（版本＞1.4）只需要：
1）编译go1.4版本，设置好GOROOT_BOOTSTRAP
2）然后再执行脚本编译安装GO1.4以上版本(任何支持的平台都可以)

注意，go的安装/移植 比较奇怪，它是以 源码包当前的路径作为根目录的，相当于`prefix =PWD`

> 有关资料: [【英文文档】 Installing Go from source Go语言官方编译指南 2019.02.27](https://www.cnblogs.com/schips/p/10465706.html)


### 开发环境介绍

- 主机操作系统：Ubuntu18.04 64位
- 目标平台：S5P6818(ARM-A53)
- 交叉工具链：arm-none-linux-gnueabi-gcc，gcc7.3.0
- Go版本：1.12 (https://github.com/golang/go/releases)

## 编译

执行`make.sh`

编译完成以后，最后会提示应该如何配置环境变量（在下文中需要用到）
> 提示：当选择开启CGO编译时必须配置先`CC_FOR_TARGET`和`CXX_FOR_TARGET`两个环境变量
> 建议 高版本的go设置CGO=0；建议 arm版本的go 设置CGO=1。


脚本中编译go的时候，用到了两个变量：

- GOOS：目标操作系统
- GOARCH：目标操作系统的架构

| OS      | ARCH              | OS version                 |
| ------- | ----------------- | -------------------------- |
| linux   | 386 / amd64 / arm | >= Linux 2.6               |
| darwin  | 386 / amd64       | OS X (Snow Leopard + Lion) |
| freebsd | 386 / amd64       | >= FreeBSD 7               |
| windows | 386 / amd64       | >= Windows 2000            |

编译其他平台的时候根据上面表格参数执行编译就可以了。

- - $GOARM (for arm only; default is auto-detected if building on the target processor, 6 if not)

    This sets the ARM floating point co-processor architecture version the  run-time should target. If you are compiling on the target system, its  value will be auto-detected.

  - - GOARM=5: use software floating point; when CPU doesn't have VFP co-processor
    - GOARM=6: use VFPv1 only; default if cross compiling; usually ARM11 or better cores (VFPv2 or better is also supported)
    - GOARM=7: use VFPv3; usually Cortex-A cores

If in doubt, leave this variable unset, and adjust it if required when you first run the Go executable. The [GoARM](https://golang.org/wiki/GoArm) page on the [Go community wiki](https://golang.org/wiki) contains further details regarding Go's ARM support.


### 设置环境变量

在自己的bash中的对应资源文件(*rc)中添加如下内容(重启命令行后生效))：
> 不同bash对应rc文件也不同，比如 .ashrc，.bashrc，.zshrc 等
> 关于 go有关的环境变量可以参考： [《GOROOT、GOPATH、GOBIN变量的含义》](https://www.cnblogs.com/schips/p/12363853.html)

```bash
# 设置 GOROOT_BOOTSTRAP是为了下次 编译的时候可以用
export GOROOT_BOOTSTRAP=根据上面脚本的编译结果
export CC_FOR_TARGET=根据上面脚本的编译结果
export CXX_FOR_TARGET=根据上面脚本的编译结果

# 一定需要的
export GOROOT=根据上面脚本的编译结果
export GOPATH=可以参考根据上面脚本的编译结果
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# 可选的，快捷命令
alias arm-go="GOOS=linux GOARCH=arm GOARM=7 go build"
alias gob="go build"
```

在`install/go_arm/`目录下会生成arm和amd64两个平台的Go命令和依赖包，所以这个版本编译的Go命令可以进行两个平台的Go应用程序开发。

```bash
# schips @ ubuntu in ~/host/go/install/go_arm/bin [20:57:41]
$ tree
.
├── go(PC上正常使用的)
├── gofmt
└── linux_arm(这个目录下的程序是在arm上运行的)
    ├── go
    └── gofmt
```

##  测试

### 验证go 是否正常运行 以及 输出版本

新开一个bash,输入 `go version` 可以进行安装的简单验证：

```bash
$ go version

go version go1.12 linux/amd64
```

### 有关程序的验证

**新建helloworld.go**

```go
package main

import "fmt"

func main() {
  fmt.Println("Hello world")
}
```

### 编译与运行

在本地运行的结果：

```bash
go build helloworld.go

./helloworld
Hello world
```

在板子上：

```bash
# 在 host 上交叉编译
GOOS=linux GOARCH=arm GOARM=7 go build helloworld.go

[root@6818 ~/nfs]#./helloworld
Hello world
```

