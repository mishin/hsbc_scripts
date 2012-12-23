#!/usr/bin/ksh

if [ $# -ne 1 ];then
  echo "Usage:$0 file_log"
  exit
fi

file=$1

cat $file|grep -v "WARN()"|grep -v "Waiting"|grep -v "is null"|awk -F',' '{print$2" "$3}'|sort >$file.fail
