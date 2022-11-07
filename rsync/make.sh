##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/

#    File Name:  make.sh
#    Created  :  Fri 22 Nov 2019 11:49:30 AM CST

##
#!/bin/bash

source ../.common

RSYNC=3.2.7
RSYNC_INSTALL=${OUTPUT_PATH}/rsync

RSYNC_APP_SH=/usr/bin/rsync.sh
RSYNC_APP_PIDFILE="/usr/local/rsync/rsyncd.pid"
#put this script in ''

download_package () {
    cd ${ARCHIVE_PATH}
    tget https://download.samba.org/pub/rsync/src/rsync-${RSYNC}.tar.gz
}

make_rsync () {
    cd $CODE_PATH/rsync-${RSYNC}

    ./configure --host=${BUILD_HOST} --prefix=${RSYNC_INSTALL} \
        --disable-ipv6 --disable-debug \
        --disable-openssl \
        --disable-xxhash \
        --disable-zstd \
        --disable-lz4

    make CC=${_CC} prefix=${RSYNC_INSTALL}  LIBS="" || return -1

    make install
}

gen_runner()
{
cat <<EOF
#!/bin/bash

#this script for start|stop rsync daemon service
#put this script to '$RSYNC_APP_SH'

status1=\$(ps -ef | egrep "rsync --daemon.*rsyncd.conf" | grep -v 'grep')
pidfile="$RSYNC_APP_PIDFILE"
start_rsync="rsync --daemon --config=/etc/rsyncd.conf"

function rsyncstart() {

    if [ "\${status1}X" == "X" ];then

        rm -f \$pidfile
　　　　 mkdir -p /usr/local/rsync/
        \${start_rsync}

        status2=\$(ps -ef | egrep "rsync --daemon.*rsyncd.conf" | grep -v 'grep')

        if [  "\${status2}X" != "X"  ];then
            echo "rsync service start.......OK"
        fi

    else
        echo "rsync service is running !"
    fi
}

function rsyncstop() {

    if [ "\${status1}X" != "X" ];then

        kill -9 \$(cat \$pidfile)

        status2=\$(ps -ef | egrep "rsync --daemon.*rsyncd.conf" | grep -v 'grep')

        if [ "\${statusw2}X" == "X" ];then

            echo "rsync service stop.......OK"
        fi
    else
        echo "rsync service is not running !"

    fi
}

function rsyncstatus() {

    if [ "\${status1}X" != "X" ];then
        echo "rsync service is running !"
    else
         echo "rsync service is not running !"
    fi

}

function rsyncrestart() {

    if [ "\${status1}X" == "X" ];then

        echo "rsync service is not running..."

        rsyncstart
    else
        rsyncstop
        for i in 1 2 3 ;
        do
                sleep 1
                echo -n "."
        done
        rsyncstart

        fi
}

case \$1 in

        "start")
               rsyncstart
                ;;

        "stop")
               rsyncstop
                ;;

        "status")
               rsyncstatus
               ;;

        "restart")
               rsyncrestart
               ;;

        *)
          echo
                echo  "Usage: \$0 start|stop|restart|status"
          echo
esac
EOF
}

gen_rsyncd()
{
cat <<EOF
#!/bin/bash

#this script for help start|stop rsync daemon service in /etc/init.d/
#put this script in '/etc/init.d/'

rsync=$RSYNC_APP_SH
pidfile="$RSYNC_APP_PIDFILE"

function  try_start
{
    count_num=\`ps -ef|grep 'rsync --daemon'|grep -v grep|wc -l\`
    echo \$count_num
    rm -f \$pidfile
    if [ \$count_num -eq 0 ];then
        \${rsync} start
    fi
}

mkdir -p \`dirname \$rsync\`
mkdir -p \`dirname \$pidfile\`
chmod +x \$rsync

test -x "\$sshd" || exit 0
case "\$1" in

    start)
        echo -n "Starting rsync daemon"
        try_start
        echo "."
        ;;

    stop)
        echo -n "Stopping rsync"
        \${rsync} stop
        echo "."
        ;;

    restart)
        echo -n "Stopping rsync"
        try_stop
        echo "."
        echo -n "Waiting for rsync to die off"
        for i in 1 2 3 ;
        do
                sleep 1
                echo -n "."
        done
        echo ""
        echo -n "Starting rsync daemon"
        \${rsync} restart
        echo "."
        ;;
    *)
        echo "Usage: \$0 {start|stop|restart}"
        exit 1
esac

exit 0

EOF
}

function gen_helper()
{
    gen_runner > ${RSYNC_INSTALL}/`basename $RSYNC_APP_SH`
    gen_rsyncd > ${RSYNC_INSTALL}/S97rsyncd.sh
}

function mk_rsync ()
{
    download_package  || return 1
    tar_package || return 1

    make_rsync  || return 1
    gen_helper
}

mk_rsync || echo "Err"
