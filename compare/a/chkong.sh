#!/usr/bin/ksh 
if [ $# -ne 2 ];then
  echo "Usage: $0 <dsjob.log> <load.log> "
  exit
fi
type=$1
dslog=$1
loadlog=$2

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
cat $dslog|grep -vf grep.conf|awk -F',' '{print $4" "$5}' | \
 sed -e 's/^.*djpEXTongoing//g' -e 's/^.*djpEXTondate//g' -e 's/^.*djpEXTdate//g' -e 's/\.log//g' | \
  sort > $dslog.$$

cat  $dslog.$$|awk '{if($2>0){print}}'> $dslog.2.$$
cat $loadlog|awk -F'[.,]' '{print$1"."$2" "$NF}'|sed 's/[#@$]/_/g' |sort> $loadlog.$$

cat  $dslog.2.$$|while read tablename dsnum;do
 grep "^$tablename "  $loadlog.$$|awk '{print$2}'|read loadnum
 if [[ ! $dsnum -eq $loadnum ]];then
   echo "$tablename $dsnum $loadnum"
 fi
done

cat $dslog|grep -v -e "Waiting" -e "^[0-9]"|wc -l|read sum
cat $dslog|grep "is null"|wc -l|read nullnum
cat $dslog|grep -i "FAIL" |wc -l|read failnum
cat $dslog.$$|awk '{if($NF==0){print}}'|wc -l|read zeronum
cat $dslog.2.$$|wc -l|read ftpnum
cat $loadlog|wc -l |read loadnum
cat $loadlog|grep "successful,"|wc -l|read loadsucc

echo ------------
echo "the sum of job: $sum"
echo "the null table: $nullnum"
echo "the fail_job  : $failnum"
echo "zero records  : $zeronum"
echo "FTP file num  : $ftpnum"
echo "the load num  : $loadnum"
echo "the succ load : $loadsucc"

rm -f  $dslog.$$  $dslog.2.$$  $loadlog.$$ 

