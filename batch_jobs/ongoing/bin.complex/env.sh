#!/usr/bin/ksh

export rootdir=/root/hsbc/script/batch_jobs/ongoing
export rootdir=/mnt3/ongoing
export filepath=/hsbc/orc/data/SAT

uname |read os
case $os in
Linux) VI="vi -n -s $rootdir/bin/null" ;;
AIX)   VI="vi" ;;
*)     echo "os not supported"
       exit ;;
esac

# create tts ongoing jobs
tts=1

