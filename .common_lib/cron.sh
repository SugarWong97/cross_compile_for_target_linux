
CRON=cronie
export CONFIG_CRON_VERSION=1.7.2
export CRON_VERSION=cronie-${CONFIG_CRON_VERSION}
export CRON_OUTPUT_PATH=${OUTPUT_PATH}/${CRON}
export CRON_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${CRON}

# 最终安装路径
export FIN_INSTALL_CRON=/usr/local
# 默认的编辑器
export CRON_EDITOR=/bin/vi

# CRON的etc目录
export CRON_SYS_CROND_DIR=$FIN_INSTALL_CRON/etc/
#export CRON_SYS_CROND_DIR=`pwd`/etc/ # DEBUG-ONLY

# CRON的VAR目录
export CRON_VAR_DIR=$FIN_INSTALL_CRON/var
#export CRON_VAR_DIR=`pwd`/var # DEBUG-ONLY
# CRON的RUN目录
export CRON_REAL_RUNDIR=$FIN_INSTALL_CRON/run
#export CRON_REAL_RUNDIR=`pwd`/run # DEBUG-ONLY

_BUILD_CRON_CONFIG_PART_FOR_TARGET_LINUX="--host=${BUILD_HOST} CC=${_CC} CXX=${_CPP}"
_BUILD_CRON_CONFIG_PART_FOR_HOST_LINUX=""
_BUILD_CRON_CONFIG_PART_COMMON=""
_BUILD_CRON_CONFIG_PART_COMMON=$(cat <<- EOF
    --with-editor=$CRON_EDITOR \
    --localstatedir=$CRON_VAR_DIR \
    --runstatedir=$CRON_REAL_RUNDIR \
    --sysconfdir=$CRON_SYS_CROND_DIR
EOF
)

download_cron () {
    tget https://github.com/cronie-crond/cronie/releases/download/cronie-${CONFIG_CRON_VERSION}/cronie-${CONFIG_CRON_VERSION}.tar.gz
}

function _gen_cron_sh () {
cat<<EOF
    ./configure \
    --prefix=${CRON_OUTPUT_PATH} ${_BUILD_CRON_CONFIG_PART_FOR_TARGET_LINUX} ${_BUILD_CRON_CONFIG_PART_COMMON}
EOF
}

function _gen_cron_sh_host () {
cat<<EOF
    ./configure \
    --prefix=${CRON_OUTPUT_PATH} ${_BUILD_CRON_CONFIG_PART_FOR_HOST_LINUX}  ${_BUILD_CRON_CONFIG_PART_COMMON}
EOF
}

function mk_cron () {
    cd ${CODE_PATH}/${CRON_VERSION}

    _gen_cron_sh_host > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make $MKTHD && make install
}

function mk_cron_host () {
    cd ${CODE_PATH}/${CRON_VERSION}

    _gen_cron_sh_host > $tmp_config
    source ./$tmp_config || return 1

    make clean
    make $MKTHD && make install
}

function gen_cron_install_helper ()
{
    install_file=$CRON_OUTPUT_PATH/install.sh
cat <<EOF > $install_file
# version $CONFIG_CRON_VERSION from https://github.com/cronie-crond/cronie
mkdir -p     $FIN_INSTALL_CRON/bin
mkdir -p     $FIN_INSTALL_CRON/sbin

mkdir -p     $CRON_SYS_CROND_DIR
mkdir -p     $CRON_VAR_DIR/spool
mkdir -p     $CRON_REAL_RUNDIR

cp   bin/*   $FIN_INSTALL_CRON/bin
cp   sbin/*  $FIN_INSTALL_CRON/sbin

#cp meta/* $CRON_SYS_CROND_DIR

echo 'Exec "crontab -e"'
echo 'Then "crond start" in "/etc/init.d/"'
EOF
    chmod +x $install_file

    rm -rf $CRON_OUTPUT_PATH/meta
    cp -rv $META_PATH $CRON_OUTPUT_PATH/meta
}

function make_cron ()
{
    export CRON_VERSION=cronie-${CONFIG_CRON_VERSION}
    download_cron  || return 1
    tar_package || return 1
    mk_cron  || return 1
    gen_cron_install_helper
}

function make_cron_host ()
{
    export CRON_VERSION=cronie-${CONFIG_CRON_VERSION}
    download_cron  || return 1
    tar_package || return 1
    mk_cron_host  || return 1
}

