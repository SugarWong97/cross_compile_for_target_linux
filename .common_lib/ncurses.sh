export NCURSES=ncurses-6.0


## for others
export NCURSES_FILE_NAME=${NCURSES}.tar.gz
export NCURSES_ARCH_PATH=$ROOT_DIR/ncurses/compressed/${NCURSES_FILE_NAME}

### NCURSES
function get_ncurses () {
    export NCURSES_FILE_NAME=${NCURSES}.tar.gz
    export NCURSES_ARCH_PATH=$ROOT_DIR/ncurses/compressed/${NCURSES_FILE_NAME}
    if [ -f "$NCURSES_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $NCURSES_ARCH_PATH $ARCHIVE_PATH/$NCURSES_FILE_NAME
        return
    else
        tget https://ftp.gnu.org/pub/gnu/ncurses/${NCURSES}.tar.gz
    fi
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
    export NCURSES_FILE_NAME=${NCURSES}.tar.gz
    export NCURSES_ARCH_PATH=$ROOT_DIR/ncurses/compressed/${NCURSES_FILE_NAME}
    get_ncurses
    tar_package       || return 1
    mk_ncurses
}
