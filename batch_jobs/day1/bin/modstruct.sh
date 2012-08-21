#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -ne 1 ]; then
  exit 9
fi

conf=$rootdir/etc/0e.$etctype.conf
tn=$1
tmp=$rootdir/tmp

cat $conf |grep "^$tn," |awk -F',' '{print $2" "$4}' |while read coln pre ; do

  echo $coln |sed 's/[@#$]/_/g' |read coln2

  # if has been done
  cat $rootdir/tb/$tn |grep -q '^  *Name "'"$coln"'_hex"'
  if [ $? -eq 0 ]; then
    continue
  fi

  # if no this coln
  cat $rootdir/tb/$tn |grep -q '^  *Name "'"$coln"'"'
  if [ $? -eq 1 ]; then
    echo "$0: column not found (warning)"
    continue
  fi

  newnum=$((pre*2))

  echo "      BEGIN DSSUBRECORD" >$tmp/$$

  cat $rootdir/tb/$tn |awk '{
if($0~/^  *Name "'"$coln"'"/){
while($0!~/^  *END DSSUBRECORD/){
print
getline
}
}
}' >>$tmp/$$
  sed -i '/^  *Name "/s/"$/_hex"/' $tmp/$$
  sed -i '/^  *Precision "/s/".*"/"'"$newnum"'"/' $tmp/$$
  echo "      END DSSUBRECORD" >>$tmp/$$

  cat $rootdir/tb/$tn |awk '{if($0~/^  *Name "'"$coln"'"/){
while($0!~/^  *END DSSUBRECORD/)getline
print FNR
}}' |read line

  sed -i "${line}r$tmp/$$" $rootdir/tb/$tn

done

rm -f $tmp/$$

