source ../.common

# 是否需要SSL支持，需要选择yes，否则no
#export IPERF_SUPPORT_SSL="no"

make_iperf || echo "Err"
