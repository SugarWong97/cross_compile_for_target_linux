#!/bin/bash

source ../.common

#export CANUTILS_OUTPUT_PATH=${OUTPUT_PATH}/canutils

#export LIBSOCKETCAN_OUTPUT_PATH=${OUTPUT_PATH}/libsocketcan
export LIBSOCKETCAN_OUTPUT_PATH=${OUTPUT_PATH}/canutils

make_canutils
