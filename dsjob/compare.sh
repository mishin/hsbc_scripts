#!/usr/bin/ksh 
if [ $# -ne 3 ];then
  echo "Usage: $0 <day1|ongoing> <dsjob.log> <load.log> "
  exit
fi
type=$1
dslog=$2
loadlog=$3

case $type in 
day1) 	
    flag=1 
;;
ongoing)
    flag=0
;;
*)  
    echo "error : $type"
    exit
esac
if [[ ! -f $dslog || ! -f $loadlog ]];then
  echo "error : $dslog or $loadlog is not exist"
  exit
fi 
if [ ! -f grep.conf ];then
  echo "error: grep.conf is not exist"
  exit
fi
echo
echo name  ds_count load_count
echo ------------
datanum=0
sum=0
cat $dslog|grep -vf grep.conf|awk -F',' '{print $4" "$((NF-1))}'|while read tb count;do
 sum=$((sum+1))
 if [ $count -gt 0 ];then
   datanum=$((datanum+1))
   tb=${tb##*djpEXTongoing}
   tb=${tb##*djpEXTdate}
   tb=${tb##*djpEXTday1}
   tb=${tb%%.log}
   if [ $flag -eq 1 ];then
     echo $tb|awk -F'.' '{print$1"."$3$2}'|read tb
     echo $tb
   fi 
   cat $loadlog|sed 's/[#@]/_/g'|grep -q "^${tb}"
   if [ $? -eq 1 ];then
      echo "error : $tb can't find in $loadlog"
   fi    
   cat $loadlog|sed 's/[#@]/_/g'|grep "^${tb}"|awk -F'[.,]' '{print $NF}'| \
   while read load_count;do
      if [[ ! "$count" == "$load_count" ]];then
         echo $tb $count $load_count
      fi 
   done
 fi 
done

echo ------------
grep "successful" $loadlog|wc -l|read loadsucc
cat $loadlog|wc -l|read loadnum
echo "job succsseful : $sum "
echo "load succsseful: $loadsucc"
echo "data num = $datanum "
echo "load num = ${loadnum}"
