
FREEIMAGE_VERSION=3180
export FREEIMAGE=freeimage
FREEIMAGE_OUTPUT=${OUTPUT_PATH}/${FREEIMAGE}


function download_freeimage () {
    #https://freeimage.sourceforge.io/download.html
    tget_and_rename  http://downloads.sourceforge.net/freeimage/FreeImage${FREEIMAGE_VERSION}.zip FreeImage.zip
    #tgit   https://github.com/WinMerge/freeimage.git
}

function mk_freeimage () {
    freeimage_dir=${CODE_PATH}/FreeImage

    cd $freeimage_dir/

    # install -d <install>/include <install>/lib
    # install -m 644 -o root -g root Source/FreeImage.h <install>/include
    # install: cannot change ownership of '<install>/include/FreeImage.h': Operation not permitted
    # Makefile.fip:74: recipe for target 'install' failed
    # make: *** [install] Error 1
    sed -i 's/ -o root -g root//' Makefile.fip

    make -f Makefile.fip clean;
    make -f Makefile.fip CC=${_CC} CXX=${_CXX} LD=${_LD} RANLIB=${_RANLIB} STRIP=${_STRIP} $MKTHD
    make -f Makefile.fip INCDIR=${FREEIMAGE_OUTPUT}/include INSTALLDIR=${FREEIMAGE_OUTPUT}/lib install;
}

function echo_freeimage_help_api()
{
    cat <<EOF
/* 代码示例 */
// 创建fipImage对象
fipImage image;

// 加载图片
BOOL bRet = image.load(const char* lpszPathName, int flag = 0);

// 缩放图片
bRet = image.rescale(unsigned new_width, unsigned new_height, FREE_IMAGE_FILTER filter);

// 裁剪图片
bRet = image.crop(int left, int top, int right, int bottom);

// 保存图片
bool = image.save(const char* lpszPathName, int flag = 0);
EOF
}

function make_freeimage ()
{
    download_freeimage  || return 1
    tar_package || return 1

    mk_freeimage
    echo_freeimage_help_api
}

