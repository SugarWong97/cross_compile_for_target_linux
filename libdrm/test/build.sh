##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Mon 02 Sep 2019 11:39:38 AM HKT
##
#!/bin/bash

cd ..

source ../.common

cd -

make clean
make CROSS_COMPILE=${BUILD_HOST_}
