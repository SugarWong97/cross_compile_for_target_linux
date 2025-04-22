#!/bin/bash

source ../.common

# 通过y/n来配置ffmpeg是否启用 Libx264, Libx265（默认启用）
#export USING_X264_FOR_FFMPEG=y
#export USING_X265_FOR_FFMPEG=y

########### 指定版本
#export CONFIG_FFMPEG_VERSION=4.2.10
#export CONFIG_X264_VERSION=snapshot-20191217-2245
#export CONFIG_X265_VERSION=3.5


########### 指定安装路径
#export FFMPEG_OUTPUT_PATH=${OUTPUT_PATH}/ffmpeg
export X264_OUTPUT_PATH=${FFMPEG_OUTPUT_PATH}
export X265_OUTPUT_PATH=${FFMPEG_OUTPUT_PATH}

#export FFMPEG_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/ffmpeg
export X264_OUTPUT_PATH_HOST=${FFMPEG_OUTPUT_PATH_HOST}
export X265_OUTPUT_PATH_HOST=${FFMPEG_OUTPUT_PATH_HOST}



# LIBX264 Config(启用libx264时有效)
### 通过y/n来配置libx264是否启用OPENCL（默认禁用）
#export USING_X264_OPENCL=n

make_ffmpeg

#make_ffmpeg_host
