#!/usr/bin/ksh 
if [ $# -ne 2 ];then
  echo "Usage: $0 <dslog> <loadlog> "
  exit
fi

type=$1
dslog=$1
loadlog=$2

if [[ ! -f $dslog || ! -f $loadlog ]];then
  echo "error : $dslog or $loadlog is not exist"
  exit
fi 

echo
echo "jobName\t dsCount\t loadCount"
echo ===================================== 

cat $dslog|grep -v -e "FAIL" -e "Waiting" -e "is null" -e "^[0-9]" |awk -F',' '{print $4" "$5}' | \
   sed -e 's/^.*djpEXTongoing//g' -e 's/^.*djpEXTondate//g' -e 's/^.*djpEXTdate//g' -e 's/\.log//g' > $dslog.$$ 
cat $loadlog|awk -F'[.,]' '{print$1"."$2" "$NF}'|sed 's/[#@$]/_/g' > $loadlog.$$ 

cat  $dslog.$$|awk '{if($2>0){print}}'|while read tablename dsnum;do 
  (cat $loadlog.$$|grep "^$tablename " || echo NULL NULL)|awk '{print $2}'|read loadnum 
  if [[  $dsnum != $loadnum ]];then 
    echo "$tablename\t $dsnum\t $loadnum" 
  fi 
done 

cat $dslog|sed '/^$/d'|grep -v -e "Waiting" -e "^[0-9]" -e "^current" | wc -l|read jobnum
cat $dslog|grep -v -e "WARN()" -e "SUCC()" -e "is null" -e "Waiting" -e "^current" -e "is null" -e "today is holiday"|sed '/^$/d'|wc -l|read abnormity
cat $dslog|grep -i "today is holiday"|wc -l|read holidaynum
cat $dslog|grep -i "FAIL"|wc -l|read failnum
cat $dslog|grep "is null"|wc -l|read nullnum
cat $dslog.$$|awk '{if($NF==0){print}}'|wc -l|read zeronum
cat $dslog.$$|awk '{if($2>0){print}}'|wc -l|read ftpnum
cat $loadlog|sed '/^$/d'|wc -l|read loadnum
cat $loadlog|grep "successful,"|wc -l|read succload
cat $loadlog|sed '/^$/d'|grep -v "succ" |wc -l|read failload

echo ===================================== 
echo "sum  job  num    :  $jobnum "
echo "abnormity job    :  $abnormity"
echo "succ get  txt    :  $ftpnum "
echo "load sum  num    :  $loadnum"
echo "succ load num    :  $succload"
echo "fail load num    :  $failload"

debug=1
if [ $debug -eq 1 ];then
echo "--------" 
echo "holiday  jobnum  :  $holidaynum"
echo "null      num    :  $nullnum"
echo "zero      num    :  $zeronum"
fi  
echo 

if [ $((failnum+nullnum+zeronum+holidaynum+ftpnum)) -ne $jobnum ];then
 echo "Datastage Extract ERROR,There are $((abnormity+nullnum+zeronum+ftpnum-$jobnum)) not match!"
fi

if [ $((failload+succload)) -ne $ftpnum ];then
 echo "Load or Transformer number ERROR, $((ftpnum-failload-succload)) is gone"
fi

rm -f  $dslog.$$ $loadlog.$$ 
 
