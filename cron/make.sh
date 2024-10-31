#!/bin/bash

source ../.common

#export CONFIG_CRON_VERSION=1.7.2
#export CRON_OUTPUT_PATH=${OUTPUT_PATH}/${CRON}
#export CRON_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${CRON}

# 最终安装路径
##export FIN_INSTALL_CRON=/usr/local

# 默认的编辑器
##export CRON_EDITOR=/bin/vi

# CRON的etc目录
##export CRON_SYS_CROND_DIR=$FIN_INSTALL_CRON/etc/

# CRON的VAR目录
##export CRON_VAR_DIR=$FIN_INSTALL_CRON/var

# CRON的RUN目录
##export CRON_REAL_RUNDIR=$FIN_INSTALL_CRON/run

make_cron
#make_cron_host
