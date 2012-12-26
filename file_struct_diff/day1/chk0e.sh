#!/usr/bin/ksh

if [ $# -ne 2 ]; then
  echo "usage: $0 hub3 ZUCAMSP1"
  exit 9
fi

img=$1
tn=$2

dir=$img.0e.dat
file=$tn.sql.out

#if [ ! -s $dir/$file ]; then
#  echo $tn >> $img.nulldat
#fi

if [ ! -f $dir/$file ]; then
  exit
fi

cat $dir/$file |tail -n 1 |awk '/record.*selected/{print $1}' |read rows
if [ "x$rows" != "x" ]; then
  echo oracle$img $tn $rows >>$img.0e.rows
  cat $dir/$file |sort -u |sed -n '/^[01]/p' |awk '{for(i=1;i<=NF;i++)if($i==1)print i}' |sort -u |while read col ; do
    cat $img/$tn |awk -F',' 'BEGIN {cnt=0} {if($3=="A"&&$4>=3&&$4<=16383)cnt++;if(cnt=='"$col"'){print;exit}}' >>$img.0e.job
  done
else
  sed -i "/ $tn\$/d" $img.list
  echo $tn >> $img.nullist
fi


