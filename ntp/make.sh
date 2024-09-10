source ../.common

## 配置NTP当前服务器IP
#export CONFIG_NTP_SERVER_IP="192.168.1.1"

## 配置NTP上一层服务器IP(可选)
#export CONFIG_NTP_OTHER_SERVER_IP="192.168.1.2"

## 配置NTP服务器drift文件路径
#export CONFIG_NTP_SERVER_DRIFTFILE"/var/ntp/drift"

## 配置NTP服务器PID文件路径
#export CONFIG_NTP_SERVER_PIDFILE="/var/run/ntpd.pid"

## 配置NTP服务器Log文件路径(建议搭建初期打开)
#export CONFIG_NTP_SERVER_LOGFILE="/var/log/ntp.log"

make_ntp
