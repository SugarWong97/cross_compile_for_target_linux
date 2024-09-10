#!/bin/bash

# 通过y/n来配置ffmpeg是否启用 Libx264, Libx265（默认启用）
#export USING_X264_FOR_FFMPEG=y
#export USING_X265_FOR_FFMPEG=y

source ../.common

#export X264_OUTPUT_PATH=${OUTPUT_PATH}/x264
export X264_OUTPUT_PATH=${OUTPUT_PATH}/ffmpeg

#export X265_OUTPUT_PATH=${OUTPUT_PATH}/x265
export X265_OUTPUT_PATH=${OUTPUT_PATH}/ffmpeg

#export FFMP_OUTPUT_PATH=${OUTPUT_PATH}/ffmpeg

#export X264_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/x264
export X264_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/ffmpeg
#export X265_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/x265
export X265_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/ffmpeg


# LIBX264 Config(启用libx264时有效)
### 通过y/n来配置libx264是否启用ASM（默认禁用）
#export USING_X264_ASM=n
### 通过y/n来配置libx264是否启用OPENCL（默认禁用）
#export USING_X264_OPENCL=n

make_ffmpeg

############ 鉴于gcc版本可能存在差异，USING_X264_ASM可能需要做调整才能编译x264

# LIBX264 Config(启用libx264时有效)
### 通过y/n来配置libx264是否启用ASM（默认禁用）
#export USING_X264_ASM=n
### 通过y/n来配置libx264是否启用OPENCL（默认禁用）
#export USING_X264_OPENCL=n

#make_ffmpeg_host
