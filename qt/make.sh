#!/bin/bash

source ../.common

## QT 版本
#export CONFIG_QT_VERSION=5.9.9
#export CONFIG_QT_DOWNLOAD_URL_PRE=qt-everywhere-opensource-src

#export CONFIG_QT_VERSION=5.12.12
#export CONFIG_QT_DOWNLOAD_URL_PRE=qt-everywhere-src

#export CONFIG_QT_VERSION=5.14.2
#export CONFIG_QT_DOWNLOAD_URL_PRE=qt-everywhere-src

export CONFIG_QT_VERSION=5.15.14
export CONFIG_QT_DOWNLOAD_URL_PRE=qt-everywhere-opensource-src



## 编译结果输出位置
#export QT_OUTPUT_PATH=${OUTPUT_PATH}/qt

## 默认启用tslib，禁用时设n即可
#export USING_TSLIB_FOR_QT=y
#export CONFIG_TSLIB_VERSION=1.4
#export TSLIB_OUTPUT_PATH=${OUTPUT_PATH}/${TSLIB}

make_qt
