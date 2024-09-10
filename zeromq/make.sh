#!/bin/bash

source ../.common

export CONFIG_ZEROMQ_LIB_VERSION=4.3.4
export CONFIG_ZEROMQ_CPP_VERSION=4.8.0
export ZEROMQ_OUTPUT_PATH=${OUTPUT_PATH}/${ZEROMQ}

make_zeromq
