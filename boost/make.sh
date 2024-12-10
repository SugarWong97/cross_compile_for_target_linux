#!/bin/bash

source ../.common

## Boost版本
#export CONFIG_BOOST_VERSION=1.86.0

## 编译结果输出位置
#export BOOST_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/boost
#export BOOST_OUTPUT_PATH=${OUTPUT_PATH}/boost

## 是否编译对应版本（默认启用；禁用改为n）
#export BUILD_BOOST_FOR_HOST=y
#export BUILD_BOOST_FOR_TARGET=y

make_boost
