#LUA_VERSION=5.2.0
LUA_VERSION=5.4.6

export LUA=lua
LUA_OUTPUT=${OUTPUT_PATH}/${LUA}

function download_lua () {
    # https://www.tecgraf.puc-rio.br/lua/ftp/
    tget   https://www.tecgraf.puc-rio.br/lua/ftp/lua-${LUA_VERSION}.tar.gz
}

function mk_lua () {
    lua_dir=${CODE_PATH}/lua-${1}*
    cd $lua_dir/
    make PLAT=linux INSTALL_TOP=${LUA_OUTPUT} clean;
    make PLAT=linux INSTALL_TOP=${LUA_OUTPUT} CC=${_CC} CXX=${_CXX} LD=${_LD} RANLIB=${_RANLIB} STRIP=${_STRIP}
    make PLAT=linux INSTALL_TOP=${LUA_OUTPUT} install;
}

function make_lua ()
{
    download_lua  || return 1
    tar_package || return 1

    mk_lua $LUA_VERSION
}
