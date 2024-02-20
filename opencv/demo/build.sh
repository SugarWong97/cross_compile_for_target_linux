#!/bin/bash

export SKIP_MK_DIR=1
source ../../.common
#rm -r source install compressed

## 指定的输出文件名
APP_NAME=cv_demo

# 指定输出目录(主目录是在编译目录中，需要使用"../"或者"绝对路径")
OUTPUT_DIR=`pwd`/out

BUILD_DIR=./.build

rm $BUILD_DIR -rf
mkdir $BUILD_DIR -p

cd $BUILD_DIR
cmake .. -DCROSS_COMPILE=${BUILD_HOST_} -DOUTPUT_APPNAME=$APP_NAME -DOUTPUT_DIRNAME=${OUTPUT_DIR}
make -j16
