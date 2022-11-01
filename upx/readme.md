# UPX

UPX (the Ultimate Packer for eXecutables)是一款先进的可执行程序文件压缩器，压缩过的可执行文件体积缩小50%-70% ，这样减少了磁盘占用空间、网络上传下载的时间和其它分布以及存储费用。

通过 UPX 压缩过的程序和程序库完全没有功能损失和压缩之前一样可正常地运行，对于支持的大多数格式没有运行时间或内存的不利后果。

UPX 支持许多不同的可执行文件格式 包含 Windows 95/98/ME/NT/2000/XP/CE 程序和动态链接库、DOS 程序、 Linux 可执行文件和核心。

## 编译

直接`./make.sh`即可生成。

生成路径为`./install/upx/upx`

## 用法

编译以后，在目标机器里面，执行 `upx -o <output-file>  <old-file>`


```
/mnt # ./upx -o new-from-upx   old-file
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2020
UPX 3.96        Markus Oberhumer, Laszlo Molnar & John Reiser   Jan 23rd 2020

        File size         Ratio      Format      Name
   --------------------   ------   -----------   -----------
   3013264 ->    961760   31.92%   linux/arm64   old-file

Packed 1 file.
```

## 注意事项

如果提示`NotCompressibleException`代表文件可能太小了，无法继续压缩。

```
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2020
UPX 3.96        Markus Oberhumer, Laszlo Molnar & John Reiser   Jan 23rd 2020

        File size         Ratio      Format      Name
   --------------------   ------   -----------   -----------
upx: uu_test: NotCompressibleException

Packed 1 file: 0 ok, 1 error.
```


## 搭配strip

先strip再upx是可以的。
