#!/bin/sh

source ../.common

####### 软件下载来源 #######
export ZLMEDIAKIT_URL=https://github.com/ZLMediaKit/ZLMediaKit
export ZLMEDIAKIT_URL=https://gitee.com/xia-chu/ZLMediaKit

####### 安装路径 #######
#export ZLMEDIAKIT_OUTPUT_PATH=${OUTPUT_PATH}/${ZLMEDIAKIT}
export OPENSSL_OUTPUT_PATH=${ZLMEDIAKIT_OUTPUT_PATH}
export FFMPEG_OUTPUT_PATH=${ZLMEDIAKIT_OUTPUT_PATH}
export X264_OUTPUT_PATH=${ZLMEDIAKIT_OUTPUT_PATH}
export X265_OUTPUT_PATH=${ZLMEDIAKIT_OUTPUT_PATH}

#export ZLMEDIAKIT_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${ZLMEDIAKIT}
export OPENSSL_OUTPUT_PATH_HOST=${ZLMEDIAKIT_OUTPUT_PATH_HOST}
export FFMPEG_OUTPUT_PATH_HOST=${ZLMEDIAKIT_OUTPUT_PATH_HOST}
export X264_OUTPUT_PATH_HOST=${ZLMEDIAKIT_OUTPUT_PATH_HOST}
export X265_OUTPUT_PATH_HOST=${ZLMEDIAKIT_OUTPUT_PATH_HOST}


######## 是否使用外部组件（默认禁用，写y启用） ########
## OpenSSL
export USING_OPENSSL_FOR_ZLMEDIAKIT="y"
## FFmpeg
export USING_FFMPEG_FOR_ZLMEDIAKIT="y"

# libx264 Config(启用ffmpeg时有效)
### 通过y/n来配置libx264是否启用ASM（默认禁用）
#export USING_X264_ASM=y
### 通过y/n来配置libx264是否启用OPENCL（默认禁用）
#export USING_X264_OPENCL=n



make_zlmediakit
make_zlmediakit_host
