
TOP_DIR=`pwd`
INSTALL_DIR=$TOP_DIR/../../install

ARMGCC=`cat ../../../.common | grep 'BUILD_HOST=' | grep -v '#' | awk -F= '{print$2}'`

gen_runtime()
{
    rm lib  include -rf
    cp $INSTALL_DIR/*/lib . -rf
    cp $INSTALL_DIR/*/include . -rf
}

do_cmake()
{
    ## 指定的输出文件名
    APP_NAME=demo

    # 指定输出目录(主目录是在编译目录中，需要使用"../"或者"绝对路径")
    OUTPUT_DIR=`pwd`/out

    BUILD_DIR=./.build

    rm $BUILD_DIR -rf
    mkdir $BUILD_DIR -p

    cd $BUILD_DIR
    cmake .. -DOUTPUT_APPNAME=$APP_NAME -DOUTPUT_DIRNAME=${OUTPUT_DIR} -DCROSS_COMPILE=${ARMGCC}-
    make -j16
}

gen_runtime
do_cmake
