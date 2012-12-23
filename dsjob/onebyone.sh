#!/bin/ksh
if [ $# -eq 0 ];then
  echo "Usage : $0 list1 [ list2 ... ]"
  exit 9
fi 
#
# Initialize direction
#
flagDir=/hsbc/orc/data/alldata
baseDir=/hsbc/orc/data/dsjob
fileSystem=/hsbc/orc/data
start=`date +%H`
#
# Start executing after 19:00 every day1 
#
while [ $start -lt 16 ];do
  echo "Current time : `date +'%Y-%m-%d %H:%M:%S'`,please wait a moment(5mins) ..."
  sleep 300 # sleep 5 mins 
  start=`date +%H`
done
#
# Run day1 script 
#
for i in $* ;do
  df -Pk $fileSystem |tail -1 |awk '{print $5}'|tr -d '%'|read currSize
  while [ -f $flagDir/data_*day1.day1flag ] || [ $currSize -gt 80 ];do
    echo "the flag file always exist or not enough storage space." 
    echo "sleep 15mins ..."
    sleep 900
    df -Pk $fileSystem |tail -1 |awk '{print $5}'|tr -d '%'|read currSize
  done
  # Sleep 5min 
  echo "sleep 5mins and then invoke extract script [joblist:$i] ..."
  sleep 300  
  # Invoke Day1 script
  if [ -f $baseDir/$i ];then
    $baseDir/concurrent.sh $i 
  fi
done
#
# Exit script
# 
exit 0

