# get_ffmpeg_information

> 获取ffmpeg版本信息

在板子上将`lib/`，`/out/`和`resource`拷贝到设备上，通过下列脚本启动：

```
TOP_DIR=`pwd`

export LD_LIBRARY_PATH=$TOP_DIR/lib/:$LD_LIBRARY_PATH

./out/demo
```

运行结果（根据ffmpeg版本的不同，打印内容也不同）：

```
FFmpeg version is: 4.0.1, avcodec version is: 3805796
.Current ffmpeg version is: 4.0.1 ,avcodec version is: 3805796=58.18.100
```
