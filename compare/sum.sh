#!/usr/bin/ksh

if [ $# -eq 0 ];then
  echo "Usage:$0 loadlog [ loadlog2 ... ]"
  exit
fi
log=`echo ${*}`
for i in $log;do
  cat $i|awk -F',' '{sum+=$NF}END{print "'$i'" " : " sum}'
done
