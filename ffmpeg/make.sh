#!/bin/bash

# 通过y/n来配置ffmpeg是否启用 Libx264, Libx265（默认启用）
#export USING_X264_FOR_FFMPEG=y
#export USING_X265_FOR_FFMPEG=y

source ../.common

# LIBX264 Config(启用libx264时有效)
### 通过y/n来配置libx264是否启用ASM（默认禁用）
#export USING_X264_ASM=n
### 通过y/n来配置libx264是否启用OPENCL（默认禁用）
#export USING_X264_OPENCL=n

make_ffmpeg || echo "Err"
#make_ffmpeg_host || echo "Err"
