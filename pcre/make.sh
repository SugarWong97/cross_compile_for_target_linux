#!/bin/sh

source ../.common

#export CONFIG_PCRE_VERSION=8.30
#export PCRE_OUTPUT_PATH=${OUTPUT_PATH}/${PCRE}

rm $PCRE_OUTPUT_PATH -rf
make_pcre
