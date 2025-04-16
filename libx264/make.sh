#!/bin/sh
source ../.common

#export CONFIG_X264_VERSION=snapshot-20191217-2245

### 通过y/n来配置libx264是否启用ASM（默认禁用）
#export USING_X264_ASM=n

### 通过y/n来配置libx264是否启用OPENCL（默认禁用）
#export USING_X264_OPENCL=n

#export X264_OUTPUT_PATH=${OUTPUT_PATH}/x264
#export X264_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/x264


#export CONFIG_X264_VERSION=snapshot-20191217-2245

make_x264
#make_x264_host
