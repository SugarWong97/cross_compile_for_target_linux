#!/bin/bash

# 是否启用 Libx264, Libx265
## 默认启用，禁用时设y即可
#export DISABLE_X264_FOR_FFMPEG=y
#export DISABLE_X265_FOR_FFMPEG=y

# LIBX264 Config(启用libx264时有效)
## 如果编译libx264时报错，可能和这些有关
export DISABLE_X264_ASM=n
export DISABLE_X264_OPENCL=n


source ../.common

make_ffmpeg || echo "Err"
