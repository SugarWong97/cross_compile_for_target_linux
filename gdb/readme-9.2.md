## 介绍

这一份gdb编译脚本适用于更新一点的gcc。

在编译的时候和以前一样，但是如果按照之前的配置，会有一个提示：

```bash
configure: error: GDB must be configured and built in a directory separate from its sources.

To do so, create a dedicated directory for your GDB build and invoke
the configure script from that directory:

      $ mkdir build
      $ cd build
      $ <full path to your sources>/gdb-VERSION/configure [etc...]
      $ make
```

即配置编译不能与源码一个目录操作，按要求创建build在build目录里再次配置编译

其他的暂时一样
