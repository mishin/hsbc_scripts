#!/usr/bin/ksh

#create tts
tts=0

export rootdir=/root/hsbc/script/batch_jobs/copy
export rootdir=/mnt3/copy
export filepath=/hsbc/orc/data/SAT

uname |read os
case $os in
Linux) VI="vi -n -s $rootdir/bin/null" ;;
AIX)   VI="vi" ;;
*)     echo "os not supported"
       exit ;;
esac

