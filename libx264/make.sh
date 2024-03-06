#!/bin/sh

export DISABLE_X264_ASM=yes

export DISABLE_X264_OPENCL=yes

source ../.common

make_x264
