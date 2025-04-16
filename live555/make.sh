#!/bin/sh
source ../.common

# history version (YYYY.MM.DD): https://download.videolan.org/pub/contrib/live555/
# current version (latest)    : http://www.live555.com/liveMedia/public/

#export CONFIG_LIVE555_VERSION=2025.01.17
export CONFIG_LIVE555_VERSION=latest

make_live555
