#!/bin/bash

# open62541 implements an OPC UA SDK with support for servers, clients and PubSub (publish-subscribe) communication.

source ../.common

## open62541版本
#export CONFIG_OPEN62541_VERSION=1.4.8

## 编译结果输出位置
#export OPEN62541_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/open62541
#export OPEN62541_OUTPUT_PATH=${OUTPUT_PATH}/open62541

## 是否编译对应版本（默认启用；禁用改为n）
#export BUILD_OPEN62541_FOR_HOST=y
#export BUILD_OPEN62541_FOR_TARGET=y

make_open62541
