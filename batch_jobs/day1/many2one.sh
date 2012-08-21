#!/usr/bin/ksh
if [ $# -ne 1 ];then
  echo "Usage:$0 dir"
  exit 
fi
dt=`date +%Y%m%d`
dir=$1
#if [ ! -f head ];then
# echo "Uasge:head isnot exist"
# exit
#fi
ls $dir/*.dsx|head -1|read first
head -11 $first >/tmp/$dt.dsx
cat $dir/*.dsx|awk '/^BEGIN DSJOB/,/^END DSJOB/{print}'>>/tmp/$dt.dsx
#cat /tmp/head /tmp/$$.dsx>/tmp/$dt.dsx
#rm /tmp/$$.dsx

#for i in $dir/*.dsx ; do
#  cat $i |awk '/^BEGIN DSJOB/,/^END DSJOB/{print}' >>./tmp/$$.dsx
#done
