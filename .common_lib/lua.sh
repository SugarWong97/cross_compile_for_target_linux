export ENABLE_LUASOCKET=yes

#LUA_VERSION=5.2.0
LUA_VERSION=5.4.6
export LUA=lua
LUA_OUTPUT=${OUTPUT_PATH}/${LUA}


# lua socket addon
LUA_SOCKET_VERSION=3.1.0
LUAV=5.4
export LUA_SOCKET=luasocket
LUASOCKET_OUTPUT=${OUTPUT_PATH}/${LUA_SOCKET}

function download_lua () {
    # https://www.tecgraf.puc-rio.br/lua/ftp/
    tget   https://www.tecgraf.puc-rio.br/lua/ftp/lua-${LUA_VERSION}.tar.gz
}

function download_luasocket () {
        tget_and_rename https://github.com/lunarmodules/luasocket/archive/refs/tags/v${LUA_SOCKET_VERSION}.tar.gz luasocket-${LUA_SOCKET_VERSION}.tar.gz
}

function mk_lua () {
    lua_dir=${CODE_PATH}/lua-${LUA_VERSION}
    cd $lua_dir/
    make PLAT=linux INSTALL_TOP=${LUA_OUTPUT} clean;
    make PLAT=linux INSTALL_TOP=${LUA_OUTPUT} CC=${_CC} CXX=${_CXX} LD=${_LD} RANLIB=${_RANLIB} STRIP=${_STRIP}
    make PLAT=linux INSTALL_TOP=${LUA_OUTPUT} install;
}

function mk_luasocket () {
    lua_src=${CODE_PATH}/lua-${LUA_VERSION}/src
    dir=${CODE_PATH}/luasocket-${LUA_SOCKET_VERSION}
    cd $dir/src
    CUST_LDFLAGS_linux="-shared -fPIC -o"
    make -C $dir LUAV=${LUAV} LUAINC_linux=${lua_src}/ LUAINC_linux_base=${lua_src}  PLAT=linux INSTALL_TOP=${LUA_OUTPUT} clean;
    make -C $dir LUAV=${LUAV} LUAINC_linux=${lua_src}/ LUAINC_linux_base=${lua_src} LDFLAGS_linux="${CUST_LDFLAGS_linux}"  PLAT=linux INSTALL_TOP=${LUA_OUTPUT} CC=${_CC} CXX=${_CXX} LD=${_LD} RANLIB=${_RANLIB} STRIP=${_STRIP}
    make -C $dir LUAV=${LUAV} LUAINC_linux=${lua_src}/ LUAINC_linux_base=${lua_src}  PLAT=linux INSTALL_TOP=${LUA_OUTPUT} install;
}

function echo_luasocket_test()
{
cat <<EOF
# 请使用下列脚本测试luasocket的可用性
--hello.lua
package.path = '/local/share/lua/${LUAV}/?.lua;'    --搜索lua模块
package.cpath = '/local/lib/lua/${LUAV}/?.so;'       --搜索so模块

local socket = require"socket"
local mime   = require"mime"
print("Hello from " .. socket._VERSION .. " and " .. mime._VERSION .. "!")
EOF
}


function make_lua ()
{
    if [ "$ENABLE_LUASOCKET" = "yes" ];then
        echo "Enable LUASOCKET"
        sleep 1
    fi

    download_lua  || return 1
    if [ "$ENABLE_LUASOCKET" = "yes" ];then
        download_luasocket
    fi
    tar_package || return 1

    mk_lua $LUA_VERSION
    if [ "$ENABLE_LUASOCKET" = "yes" ];then
        mk_luasocket
        echo_luasocket_test
    fi
}
