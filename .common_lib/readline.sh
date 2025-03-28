export READLINE=readline-6.3
READLINE_OUTPUT=${OUTPUT_PATH}/${READLINE}

## for others
export READLINE_FILE_NAME=${READLINE}.tar.gz
export READLINE_ARCH_PATH=$ROOT_DIR/readline/compressed/${READLINE_FILE_NAME}
export READLINE_CONFIGURE_ADD=""

### READLINE
function get_readline () {
    export READLINE_FILE_NAME=${READLINE}.tar.gz
    export READLINE_ARCH_PATH=$ROOT_DIR/readline/compressed/${READLINE_FILE_NAME}
    if [ -f "$READLINE_ARCH_PATH" ]; then
        mkdir -p $ARCHIVE_PATH
        mk_softlink_to_dest $READLINE_ARCH_PATH $ARCHIVE_PATH/$READLINE_FILE_NAME
        return
    else
        tget ftp://ftp.gnu.org/gnu/readline/${READLINE}.tar.gz
    fi
}

function mk_readline () {
    cd ${CODE_PATH}/${READLINE}
    file_replace_match_lines configure 'cross_compiling\" = yes;' 'if test \"\$cross_compiling\" = no; then :'
bash <<EOF
    export cross_compiling=yes
    ./configure CC=${_CC} --host=${BUILD_HOST} \
        --enable-static  $READLINE_CONFIGURE_ADD \
        CROSS_COMPILE=${BUILD_HOST_}gcc  --prefix=${READLINE_OUTPUT}
    make clean
    make $MKTHD && make install
EOF
}

function make_readline () {
    export READLINE_FILE_NAME=${READLINE}.tar.gz
    export READLINE_ARCH_PATH=$ROOT_DIR/readline/compressed/${READLINE_FILE_NAME}
    get_readline
    tar_package       || return 1
    mk_readline
}
