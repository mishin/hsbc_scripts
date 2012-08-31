#!/bin/ksh

basedir=/sybiq/script 
datestamp=`date +"%Y%m%d%H%M%S"`


#for i in ongoing ttsongoing ondate ttsondate;do
for dir in day1 ;do
 cd $basedir/data_${dir} 2>/dev/null || exit 0 
 for i in *.TXT;do
   ls $i
 done > ${dir}.${datestamp}.lst 2>/dev/null || echo "txt is not exist!" 
 
 cat ${dir}.${datestamp}.lst | grep -q "^[A-Z].*\.TXT"
   if [ $? -eq 0 ];then
     cat ${dir}.${datestamp}.lst | while read file;do
       mv $file a/$file 
       sleep 5
       echo `date +%H%M%S` >>${dir}.${i}.${datestamp}.log
     done  
   fi
done
