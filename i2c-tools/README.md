## 介绍

[i2c-tool](https://i2c.wiki.kernel.org/index.php/I2C_Tools)是一个专门调试i2c的开源工具。可获取挂载的设备及设备地址，还可以在对应的设备指定寄存器设置值或者获取值等功能，对于驱动以及应用开发者比较友好。

i2c-tool：[v3.0.3](https://mirrors.edge.kernel.org/pub/software/utils/)

## 移植

直接执行对应版本的`make_X.sh`即可。

拷贝`install/i2c-tools/sbin`中的文件即可运行。

```bash
i2c_tools/sbin# ls
i2c-stub-from-dump  i2cdetect           i2cdump             i2cget              i2cse
```

## 使用

为了避免混淆，假定拷贝好的`i2c-tools`已经配进`PATH`变量中。

```bash
-y ------- 取消用户交互，直接执行
-f ------- 强制执行
```



### 列举总线数目

```bash
# i2cdetect -l

i2c-1	i2c       	Cadence I2C at e0005000         	I2C adapter
i2c-0	i2c       	Cadence I2C at e0004000         	I2C adapter
```

### 查询i2c总线上设备及设备的地址

```bash
i2cdetect -y 0 # 例如总线 0

Error: Can't use SMBus Quick Write command on this bus
```

因为配置的问题，所以失败了。这里引用别人的结果：

```
i2cdetect -r -y 4                           
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- -- 
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
40: -- -- -- -- -- -- -- -- -- 49 -- -- -- -- -- -- 
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
```

可看出，在i2c 总线4上有1个设备地址为`0x40`

### 读取i2c上的设备寄存器

`i2cdump`命令可以列出整个设备的内容。

如果无法读取，则显示`XX`。

```bash
i2cdump -f  -y 1 0x68 
# 1 代表 i2c-1 总线
# 0x68 代表 设备地址
No size specified (using byte-data access)
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f    0123456789abcdef
00: 28 52 23 02 02 01 00 b3 40 20 71 04 96 28 48 03    (R#???.?@ q??(H?
10: 80 00 42 c8 05 02 40 30 20 00 20 08 00 55 44 22    ?.B???@0 . ?.UD"
20: 49 a9 24 28 48 10 44 20 21 f1 2d a2 04 00 43 8c    I?$(H?D !?-??.C?
30: 50 24 00 24 20 2c 14 20 01 a0 01 89 02 00 21 88    P$.$ ,? ?????.!?
40: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
50: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
60: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
70: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
80: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
90: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
a0: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
b0: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
c0: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
d0: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
e0: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
f0: XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX XX    XXXXXXXXXXXXXXXX
```

`i2cget`可以读取一个值

```bash
i2cget -f -y 1 0x68  0x3f
# 0x3f 由 0x30 上的 f 得到，对应上面dump结果的 最后一个有效值。
88

i2cget -f -y 1 0x68  0
# 同理，得到上面的第一个有效值 28
28
```

### 写入值到i2c上的设备寄存器

```
i2cset -y -f 0 0x50 0x00 0x11
# 0：i2c-0
# 0x50 ： 设备地址
# 0x00 ：寄存器偏移
# 0x11 ：写入值
```

### i2ctransfer

```bash
## 读取n个字节
i2ctransfer  -f -y ${I2C_BUS_ID}  w${SEND_COUNT}@${I2C_DEVICE_ID_7BIT}  ${DEVICES_ADDR_H} ${DEVICES_ADDR_L} r${COUNT}
## 读取 ${I2C_BUS_ID} 总线上 的 I2C_DEVICE_ID_7BIT设备，上 ${DEVICES_ADDR_H}${DEVICES_ADDR_L} 寄存器， 长度为 COUNT
## w2@ : 写2个字节，这是固定写法。
```


#### 16位寄存器地址、8位值的设备寄存器读写

##### read

```bash
i2ctransfer  -f -y ${I2C_BUS_ID}  w2@${I2C_DEVICE_ID_7BIT}  ${DEVICES_ADDR_H} ${DEVICES_ADDR_L} r${COUNT}
## 读取 ${I2C_BUS_ID} 总线上 的 I2C_DEVICE_ID_7BIT设备，上 ${DEVICES_ADDR_H}${DEVICES_ADDR_L} 寄存器， 长度为 COUNT
## w2@ : 写2个字节，这是固定写法。
```

例如：

```bash
#e.g
i2ctransfer  -f -y  1  w2@0x60    0x02 0xd3    r1
## 读取 i2c-1 总线上 的 0x60设备，上 0x02d3 寄存器， 长度为 1
```

##### write

```bash
i2ctransfer  -f -y ${I2C_BUS_ID}  w3@0${I2C_DEVICE_ID_7BIT}  ${DEVICES_ADDR_H} ${DEVICES_ADDR_L} ${VALUE}
-f -y ${I2CBUS} w3@${I96712_ADDR} 0x04 0x0B 0x02
## 往 ${I2C_BUS_ID} 总线上 的 I2C_DEVICE_ID_7BIT设备，上 ${DEVICES_ADDR_H}${DEVICES_ADDR_L} 寄存器， 写入 ${VALUE}
## w3@ : 固定操作。
```

例如：

```bash
#e.g
i2ctransfer  -f -y  1  w3@0x60    0x02 0xd3    0xff
## 往 i2c-1 总线上 的 0x60设备，上 0x02d3 寄存器写入 0xff， 长度为 1
```


#### 16位寄存器地址、16位值的设备寄存器读写

##### read

```bash
i2ctransfer  -f -y ${I2C_BUS_ID}  w2@${I2C_DEVICE_ID_7BIT}  ${DEVICES_ADDR_H} ${DEVICES_ADDR_L} r2
## 读取 ${I2C_BUS_ID} 总线上 的 I2C_DEVICE_ID_7BIT设备，上 ${DEVICES_ADDR_H}${DEVICES_ADDR_L} 寄存器， 长度为2
## w2@ : 写2个字节，这是固定写法。
```

如果想操作多个，r可以一直写（只要设备支持）
例如：

```bash
i2ctransfer -y -f 1 w2@0x48 0x00 0x20 r2
# 其中参数1为i2c1，w2表示写两个字节，@0x48为你的i2c设备（注意要右移一位），0x00 0x20 为地址，r16为读取的数据。

#如果想操作多个，r可以一直写（只要设备支持）
i2ctransfer -y -f 1 w2@0x48 0x00 0x20 r16
```
##### write

```bash
i2ctransfer  -f -y ${I2C_BUS_ID}  w4@${I2C_DEVICE_ID_7BIT}  ${DEVICES_ADDR_H} ${DEVICES_ADDR_L} ${VALUE_H} ${VALUE_L}
## 往 ${I2C_BUS_ID} 总线上 的 I2C_DEVICE_ID_7BIT设备，上 ${DEVICES_ADDR_H}${DEVICES_ADDR_L} 寄存器，写入${VALUE_H}{VALUE_L}
## w4@ : 发送4个字节，这是固定写法。
```

例如：

```bash
#e.g
i2ctransfer -y -f 1 w4@0x48 0x00 0x20 0x00 0x77
1为i2c1，w4表示写入四个字节，@0x48为你的i2c设备（注意要右移一位），0x00 0x20 为地址，0x00 0x77为写入的数据。
```

