##
#    Copyright By Schips, All Rights Reserved

BUILD_HOST=arm-linux
OUTPUT=`pwd`/install
#cd ./ntfs-3g_ntfsprogs-2017.3.23
cd ./ntfs-3g*
./configure --host=${BUILD_HOST} CC=${BUILD_HOST}-gcc   AR=${BUILD_HOST}-ar  --prefix=${OUTPUT}/usr --exec-prefix=${OUTPUT} && make 

echo <<EOF

得到： ntfs-3g（${OUTPUT}/bin） 以及 libntfs-3g.so.0.0.0 （${OUTPUT}/lib）
拷贝到对应的arm板目录中即可
EOF

#make install

# 参考 : https://www.cnblogs.com/schips/protected/p/11713617.html
