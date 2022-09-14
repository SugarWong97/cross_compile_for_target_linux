##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Fri 22 Nov 2019 11:49:30 AM CST

##
#!/bin/sh

source ../.common

MEMTESTER=memtester-4.5.1
MEMTESTER_INSTALL=${OUTPUT_PATH}/${MEMTESTER}

download_package () {
    cd ${BASE}/compressed
    tget https://pyropus.ca./software/memtester/old-versions/${MEMTESTER}.tar.gz
}

make_memtester () {
    mkdir -p ${MEMTESTER_INSTALL}

    cd $CODE_PATH/${MEMTESTER}
    ${_CC} memtester.c  tests.c  -o ${MEMTESTER_INSTALL}/memtester
}

function make_build ()
{
    download_package  || return 1
    tar_package || return 1

    make_memtester  || return 1
}

make_build || echo "Err"
