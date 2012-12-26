#!/usr/bin/ksh

img=hub3

cat data.lst |while read tn ; do

cat tmp3/out/$tn.sql.out |sed -n '/^[01]/p' |awk '{for(i=1;i<=NF;i++)if($i==1)print i}' |\
  sort -u |while read col ; do
  cat $img/$tn |awk -F',' 'BEGIN {cnt=0}
{
if(($3=="A"||$3=="O")&&$4<=16383)cnt++
if(cnt=='"$col"') {
print
exit
}
}'

done

done
