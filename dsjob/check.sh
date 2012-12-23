#!/usr/bin/ksh

if [ $# -eq 0 ]; then
exit
fi

date=$1

cat jobs.lst |awk '{print $2}' |while read tn ; do

echo djpEXTday1$tn |sed 's/[#@]/_/g' |read job

ls -1crt log/$date/$job.*.log |tail -1 |read fn

cat $fn |grep "records exported successfully" |awk '{print $4" "$8}' |read rowsucc rowfail


echo $tn $rowsucc $rowfail

done
