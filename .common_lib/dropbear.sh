
DROPBEAR=dropbear
export CONFIG_DROPBEAR_VERSION=2024.85
export DROPBEAR_VERSION=${DROPBEAR}-${CONFIG_DROPBEAR_VERSION}
export DROPBEAR_OUTPUT_PATH=${OUTPUT_PATH}/${DROPBEAR}

#下载包
download_dropbear () {
    get_zlib
    tget  https://matt.ucc.asn.au/dropbear/dropbear-${CONFIG_DROPBEAR_VERSION}.tar.bz2
}

mk_dropbear () {
    cd ${CODE_PATH}/${DROPBEAR_VERSION}

    ./configure \
    --host=arm \
    --prefix=${DROPBEAR_OUTPUT_PATH} \
    --with-zlib=${ZLIB_OUTPUT_PATH} \
    --enable-static \
    CC=${_CC} \
    AR=${_AR}

    make $MKTHD
    make scp
    make install
}

echo_dropbear_help() {
cat <<EOF
-----------------------------------
#in target:

mkdir -p /usr/sbin/
mkdir -p /etc/dropbear/

cd <dropbear-path>
cp bin/* sbin/* /usr/bin

cd /etc/dropbear
dropbearkey -t rsa -f dropbear_rsa_host_key
dropbearkey -t dss -f dropbear_dss_host_key

/usr/sbin/dropbear -p 22
EOF
}

make_dropbear ()
{
    download_dropbear
    tar_package
    make_zlib || { echo >&2 "make_zlib "; exit 1; }
    mk_dropbear  || { echo >&2 "make_ssh "; exit 1; }
    echo_dropbear_help
    echo_dropbear_help > $DROPBEAR_OUTPUT_PATH/init.sh
}
