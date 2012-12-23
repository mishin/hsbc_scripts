#!/usr/bin/ksh

if [ $# -ne 1 ];then
 echo "Usage: $0 log"
 exit
fi

log=$1

cat $log|grep -v -e "is null" -e "WARN()" -e "Waiting" -e "today is holiday"
