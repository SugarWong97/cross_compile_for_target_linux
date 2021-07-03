#/** @file         make.sh
#*  @author       Schips
#*  @date         2020-10-28 23:22:53
#*  @version      v1.0
#*  @copyright    Copyright By Schips, All Rights Reserved
#*
#**********************************************************
#*
#*  @par 修改日志:
#*  <table>
#*  <tr><th>Date       <th>Version   <th>Author    <th>Description
#*  <tr><td>2020-10-28 <td>1.0       <td>Schips    <td>创建初始版本
#*  </table>
#*
#**********************************************************
#*/

#!/bin/sh

source ../.common || return 1

download_package () {
    cd ${BASE}/compressed
    tget https://udomain.dl.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.45.6/e2fsprogs-1.45.6.tar.gz
}

function make_e2fsprogs () {
function _make_sh () {
cat<<EOF
    CC=${BUILD_HOST}-gcc ../configure --host=arm-linux --enable-elf-shlibs \
        --prefix=${E2FSPROGS_OUTPUT_PATH}/ \
        --datadir=${E2FSPROGS_OUTPUT_PATH}/doc \
		--with-udev-rules-dir=${E2FSPROGS_OUTPUT_PATH} \
		--with-crond-dir=${E2FSPROGS_OUTPUT_PATH} \
		--with-systemd-unit-dir=${E2FSPROGS_OUTPUT_PATH}
EOF
}

    local E2FSPROGS_OUTPUT_PATH=${OUTPUT_PATH}/e2fsprogs

    cd ${BASE}/source/e2fsprogs*

    mkdir configure_dir -p
    cd configure_dir

    _make_sh > $tmp_config
    source ./$tmp_config || return 1
    
    make clean
    make  $MKTHD && make install
}

function make_build ()
{
    download_package  || return 1
    tar_package  || return 1
    make_e2fsprogs  || return 1
}

make_build || echo "Err"
