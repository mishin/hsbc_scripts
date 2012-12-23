#!/usr/bin/ksh

if [ $# -eq 0 ];then
 echo "Usage: $0 log1 [log2 ] ... "
 exit
fi

for i in $* ;do
  log=$i
  cat $log|grep -v -e "is null" -e "WARN()" -e "Waiting" -e "today is holiday"
  echo "---------------------------"
done
