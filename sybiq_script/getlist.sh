#!/usr/bin/ksh
if [ $# -ne 1 ];then
 echo "Usage:$0 <dir> "
 exit
fi
dir=$1
if [ ! -d $dir ];then
 echo "$dir is not exist"
 exit
fi
cd  $dir

for i in *.TXT;do
 ls -l $i
done |awk '{if($5>0){print$5" "$9}}'|sort
