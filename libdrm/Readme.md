# libdrm

## 移植要求
移植libdrm，老版本可以使用`make.leagcy.sh`

如果有meson环境，可以试试`make.meson.sh`

## 测试

### 原生的测试

使用 `modetest` 可以测试进行有关的测试。


例如：
```bash
modetest  | grep -E ^[0-9A-Z]\|id
```

得到有关的ID以后，使用下列内容进行测试。
```bash
modetest -M rockchip -s 197@68:1920x1080
```

### 自定义程序测试

见`test`目录，直接`./build.sh`即可。

注意检查有关的Connector、CRTC和显示器是否支持有关的模式（分辨率）
