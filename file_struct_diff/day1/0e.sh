#!/usr/bin/ksh

if [ $# -ne 2 ]; then
  echo "Usage: $0 [hub|tts] filename"
  exit 9
fi

type=$1
file=$2
basedir=`dirname $0`
tmpdir=/tmp
tn=${file##*/}
tn=${tn%%.*}

conf=$basedir/0e.$type.conf
if [ ! -f $conf ]; then
  echo "$conf not found"
  exit 9
fi

cat $conf |grep -q "^$tn,"
if [ $? -eq 1 ]; then
  echo "$tn not found in $conf"
  exit 9
fi

cp -f $file $tmpdir/$$

cat $conf |awk -F',' '{if($1=="'"$tn"'")print $2" "$4}' |while read coln num ; do
  newnum=$((num*2))
  sed -i "/^$tn,$coln,/{
h
s/^\([^,]\+\),\([^,]\+\),\([^,]\+\),\([^,]\+\),\([^,]\+\),\([^,]\+\)/\1,\2_hex,A,$newnum,\5,\6/
H
x
}" $tmpdir/$$

done

cat $tmpdir/$$

rm -f $tmpdir/$$

