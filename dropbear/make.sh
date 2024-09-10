#!/bin/sh

source ../.common

#export DROPBEAR_OUTPUT_PATH=${OUTPUT_PATH}/${DROPBEAR}

#export ZLIB_OUTPUT_PATH=${OUTPUT_PATH}/${ZLIB}
export ZLIB_OUTPUT_PATH=${OUTPUT_PATH}/${DROPBEAR}

make_dropbear
