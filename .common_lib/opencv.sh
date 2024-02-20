#!/bin/bash

#export OPENCV_VERSION=2.4.13.6
#export OPENCV_VERSION=3.4.1
export OPENCV_VERSION=3.4.16
#export OPENCV_VERSION=4.5.5

export OPENCV=opencv-${OPENCV_VERSION}


# 是否使用OpenCV第三方库（不为0即代表使用opencv_contrib）
# 使用这个外部库的时候还需要联网下载其他的有关部分(否则可能会导致失败)
# 只有opencv 3.0 以上的版本才有CONTRIB，如果你选了是2的版本，此项无效
export USING_OPENCV_CONTRIB=0

export OPENCV_CONTRIB=opencv_contrib-${OPENCV_VERSION}

OPENCV_OUTPUT_DIR=${OUTPUT_PATH}/opencv

download_opencv_234 () {
    tget_and_rename https://github.com/opencv/opencv/archive/refs/tags/${OPENCV_VERSION}.tar.gz ${OPENCV}.tar.gz
    if [ ${USING_OPENCV_CONTRIB} -ne 0 ];then
        tget_and_rename https://github.com/opencv/opencv_contrib/tags/archive/refs/tags/${OPENCV_VERSION}.tar.gz ${OPENCV_CONTRIB}.tar.gz
    fi
}

tmp_file=/tmp/.$$.$USER.opencv.cmake

function gen_opencv_cmake_toolchain_file() {
(
cat <<EOF
set( CMAKE_SYSTEM_NAME Linux )

set( CMAKE_SYSTEM_PROCESSOR arm )
#set( CMAKE_SYSTEM_PROCESSOR aarch64) # arm

set( CMAKE_C_COMPILER ${_CC} )
set( CMAKE_CXX_COMPILER ${_CPP} )

#set( WORDS_BIGENDIAN 0)

#set( HAVE_CXX_MSSE 0    )
#set( HAVE_CXX_MSSE2 0   )
#set( HAVE_CXX_MSSE3 0   )
#set( HAVE_CXX_MSSE4_1 0 )
#set( HAVE_CXX_MSSE4_2 0 )
EOF
) > $tmp_file

}

function make_opencv_234 () {
    gen_opencv_cmake_toolchain_file
    cmake_cmd_arg_for_opencv_contrib=""
    if [ ${USING_OPENCV_CONTRIB} -ne 0 ];then
        cmake_cmd_arg_for_opencv_contrib="-D OPENCV_EXTRA_MODULES_PATH=${CODE_PATH}/${OPENCV_CONTRIB}/modules/"
    fi
bash <<EOF
    cd ${CODE_PATH}/${OPENCV}

    CMAKE_EXE_LINKER_FLAGS="-lpthread -ldl"
    CMAKE_EXE_LINKER_FLAGS="-lpthread"

    rm ${CODE_PATH}/${OPENCV}/build -rf
    mkdir ${CODE_PATH}/${OPENCV}/build -p
    cd ${CODE_PATH}/${OPENCV}/build
    cp -v $tmp_file ${_CC}.cmake

    cmake ../ -D CMAKE_BUILD_TYPE=Release \
     -D CMAKE_INSTALL_PREFIX=${OPENCV_OUTPUT_DIR} \
     -D CMAKE_TOOLCHAIN_FILE=${_CC}.cmake \
     -D CMAKE_C_COMPILER=${_CC} \
     -D BUILD_SHARED_LIBS=ON \
     -D CMAKE_CXX_FLAGS=-fPIC \
     -D CMAKE_C_FLAGS=-fPIC \
     -D CMAKE_EXE_LINKER_FLAGS="${CMAKE_EXE_LINKER_FLAGS}" \
     -D ENABLE_PIC=ON \
     -D WITH_1394=OFF \
     -D WITH_ARAVIS=OFF \
     -D WITH_ARITH_DEC=ON \
     -D WITH_ARITH_ENC=ON \
     -D WITH_CLP=OFF \
     -D WITH_CUBLAS=OFF \
     -D WITH_CUDA=OFF \
     -D WITH_CUFFT=OFF \
     -D WITH_FFMPEG=ON \
     -D WITH_GSTREAMER=ON \
     -D WITH_GSTREAMER_0_10=OFF \
     -D WITH_HALIDE=OFF \
     -D WITH_HPX=OFF \
     -D WITH_IMGCODEC_HDR=ON \
     -D WITH_IMGCODEC_PXM=ON \
     -D WITH_IMGCODEC_SUNRASTER=ON \
     -D WITH_INF_ENGINE=OFF \
     -D WITH_IPP=OFF \
     -D WITH_ITT=OFF \
     -D WITH_JASPER=ON \
     -D WITH_JPEG=ON \
     -D WITH_LAPACK=ON \
     -D WITH_LIBREALSENSE=OFF \
     -D WITH_NVCUVID=OFF \
     -D WITH_OPENCL=OFF \
     -D WITH_OPENCLAMDBLAS=OFF \
     -D WITH_OPENCLAMDFFT=OFF \
     -D WITH_OPENCL_SVM=OFF \
     -D WITH_OPENEXR=OFF \
     -D WITH_OPENGL=OFF \
     -D WITH_OPENMP=OFF \
     -D WITH_OPENNNI=OFF \
     -D WITH_OPENNNI2=OFF \
     -D WITH_OPENVX=OFF \
     -D WITH_PNG=OFF \
     -D WITH_PROTOBUF=OFF \
     -D WITH_PTHREADS_PF=ON \
     -D WITH_PVAPI=OFF \
     -D WITH_QT=OFF \
     -D WITH_QUIRC=OFF \
     -D WITH_TBB=OFF \
     -D WITH_TIFF=ON \
     -D WITH_VULKAN=OFF \
     -D WITH_WEBP=OFF \
     -D WITH_XIMEA=OFF \
     -D BUILD_ZLIB=ON \
     -D   WITH_GTK=OFF  ${cmake_cmd_arg_for_opencv_contrib}

 #   -D BUILD_ZLIB=ON \
 #   -D ZLIB_INCLUDE_DIR=../3rdparty/zlib ../ \

    make  $MKTHD
    make install
EOF
}

function build_opencv_234 ()
{
    echo "OpenCV Version : $OPENCV"
    sleep 1
    download_opencv_234 || return 1
    tar_package || return 1
    make_opencv_234 || return 1
}

