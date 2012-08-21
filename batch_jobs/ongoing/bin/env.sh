#!/usr/bin/ksh

# create tts ongoing jobs
#tts=1

export rootdir=/home/yyt/hsbc_script/batch_jobs/ongoing
#export rootdir=/pub/script/proj_oracle/batch_jobs/ongoing

uname |read os
case $os in
Linux) VI="vi -n -s $rootdir/bin/null" ;;
AIX)   VI="vi" ;;
*)     echo "os not supported"
       exit ;;
esac

