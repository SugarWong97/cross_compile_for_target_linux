export NCURSES=ncurses-6.0


## for others
export NCURSES_FILE_NAME=${NCURSES}.tar.gz
export NCURSES_ARCH_PATH=$ROOT_DIR/ncurses/compressed/${NCURSES_FILE_NAME}

function _sync_export_var_ncurses()
{
    export NCURSES_FILE_NAME=${NCURSES}.tar.gz
    export NCURSES_ARCH_PATH=$ROOT_DIR/ncurses/compressed/${NCURSES_FILE_NAME}
}

### NCURSES
function get_ncurses () {
    _sync_export_var_ncurses
    tget_package_from_arch $NCURSES_ARCH_PATH  $ARCHIVE_PATH/$NCURSES_FILE_NAME https://ftp.gnu.org/pub/gnu/ncurses/${NCURSES}.tar.gz
}

function mk_ncurses () {
    cd ${CODE_PATH}/${NCURSES}
    ./configure  --prefix=${OUTPUT_PATH}/${NCURSES} \
      --host=${BUILD_HOST} --target=${BUILD_HOST} \
    --without-cxx --without-cxx-binding --without-ada --without-manpages --without-progs --without-tests --with-shared

    # 防止recipe for target '../objects/lib_gen.o' failed编译错误
    echo "exit 0" > ncurses/base/MKlib_gen.sh

    make clean
    make $MKTHD && make install
}

function make_ncurses () {
    _sync_export_var_ncurses
    get_ncurses
    tar_package       || return 1
    mk_ncurses
}
