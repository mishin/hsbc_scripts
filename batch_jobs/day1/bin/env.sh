#!/usr/bin/ksh

day1=1
#tts=0

export rootdir=/home/yyt/hsbc_script/batch_jobs/day1
#export rootdir=/pub/script/proj_oracle/batch_jobs/day1
#export filepath=/hsbc/orc/data/tmp

uname |read os
case $os in
Linux) VI="vi -n -s $rootdir/bin/null" ;;
AIX)   VI="vi" ;;
*)     echo "os not supported"
       exit ;;
esac

export yang='¥'

