# get_video_information

> 解码文件

在板子上将`lib/`，`/out/`和`../resource`拷贝到设备上，通过下列脚本启动：

```
TOP_DIR=`pwd`

export LD_LIBRARY_PATH=$TOP_DIR/lib/:$LD_LIBRARY_PATH

./out/demo
```

运行结果：

```
Input #0, mov,mp4,m4a,3gp,3g2,mj2, from 'resource/lenna-500X500.mp4':
  Metadata:
    major_brand     : isom
    minor_version   : 512
    compatible_brands: isomiso2avc1mp41
    encoder         : Lavf61.1.100
  Duration: 00:00:10.00, start: 0.000000, bitrate: 9 kb/s
    Stream #0:0(und): Video: h264 (High 4:4:4 Predictive) (avc1 / 0x31637661), yuv444p(tv, unknown/bt709/iec61966-2-1), 100x100 [SAR 1:1 DAR 1:1], 5 kb/s, 25 fps, 25 tbr, 12800 tbn, 50 tbc (default)
    Metadata:
      handler_name    : VideoHandler
      encoder         : Lavc61.3.100 libx264
There are 250 frames int total.
```
