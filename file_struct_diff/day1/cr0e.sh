#!/usr/bin/ksh

img=${1%%/*}
tn=${1##*/}

echo "select "
head=""
cat $1 |awk -F',' '{if($3=="A"&&$4>=3&&$4<=16383)print$2}' |while read col ; do
  echo "${head}case when locate(X'0E',$col)=0 then '0' else '1' end as $col"
  head=","
done
echo "from oracle$img.$tn ;"

