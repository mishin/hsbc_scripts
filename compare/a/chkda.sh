#!/usr/bin/ksh 
if [ $# -ne 4 ];then
  echo "Usage: $0 <image> <db2.log> <dsjob.log> <load.log> "
  exit
fi

image=$1
db2log=$2
dslog=$3
loadlog=$4
case $image in
oraclehub1|oracletts1)
  i=1
;;
oraclehub2|oracletts2)
  i=2
;;
oraclehub3|oracletts3)
  i=3
;;
oraclehub4|oracletts4)
  i=4
;;
*)
 echo "error:image"
 exit
esac

if [[ ! -f $db2log || ! -f $dslog || ! -f $loadlog ]];then
  echo "error : $db2log ,$dslog or $loadlog is not exist"
  exit
fi 
if [ ! -f grep.conf ];then
  echo "error: grep.conf is not exist"
  exit
fi
echo
echo tableName  db2_count  ds_count load_count
echo ------------

cat $dslog|grep "^$image,"|grep -vf grep.conf|awk -F',' '{if($5>0){print $2" "$5}}'|sed 's/[@#$]/_/g'>$dslog.$$

cat $loadlog|grep "${i}.TXT"|awk -F'[.,]' '{print$1" "$NF}'|sed 's/[#@]/_/g' |sort>$loadlog.$$

cat $db2log|sed 's/[#@$]/_/g'|while read tablename db2num;do
 (cat $dslog.$$|grep "^$tablename " ||echo NULL NULL)|awk '{print$2}'|read dsnum
 (cat $loadlog.$$|grep "^$tablename " ||echo NULL NULL)|awk '{print$2}'|read loadnum
 if [[ $db2num != $dsnum || $db2num != $loadnum ]];then
  echo "$tablename $db2num $dsnum $loadnum"
 fi
done 

echo ------------
grep -i FAIL $dslog|wc -l|read failjob
grep "is null" $dslog|wc -l|read nullnum
cat $dslog|grep "^$image,"|grep -vf grep.conf|awk -F',' '{if($5=0){print}}'|wc -l|read zero
cat $dslog.$$|wc -l|read ftpnum
cat $dslog|grep -v -e "Waiting" -e "^[0-9]" |wc -l |read jobsum
grep -v "successful" $loadlog|wc -l|read loadfail
grep "successful" $loadlog|wc -l|read loadsucc
cat $loadlog|wc -l|read loadsum

echo "fail job   :  $failjob"
echo "Table null :  $nullnum"
echo "zero record:  $zero"
echo "ftp sum    :  $ftpnum"
echo "RunJob sum :  $jobsum"
if [ $((failjob+nullnum+zero+ftpnum+jobsum)) -eq $jobsum ];then
  echo "the job sum is right"
else 
  echo "the job sum is wrong!!!"
fi
echo "----------------------"
echo "Load fail  :  $loadfail"
echo "load succ  :  $loadsucc"
echo "load sum   :  $loadsum"
if [ $((loadfail+loadsucc)) -eq $loadsum ];then
  echo "the load sum is right"
else
  echo "the load sum is wrong!!!"
fi 


rm -f $dslog.$$ $loadlog.$$ 

