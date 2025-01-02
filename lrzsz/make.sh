#export SKIP_CHECK_TARGET_GCC=y
source ../.common

#make_lrzsz

make_lrzsz_host || echo "Err"
