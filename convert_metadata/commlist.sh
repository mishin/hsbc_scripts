#!/usr/bin/ksh
cd t
grep -El '^[^,]+,[^,]+6,' * |while read a ; do
  cat $a |grep -E '^[^,]+,[^,]+6,' |awk -F',' '{print $1" "$2" "$3" "$4}' |while read f1 f2 f3 f4 ; do
    if [ $f3 != "A" ]; then
      continue
    fi
    if [ $f4 -lt 10 ]; then
      continue
    fi
    grep -q ${f2%6}5 $a
    last5=$?
    grep -q ${f2%6}4 $a
    last4=$?
    grep -q ${f2%6}3 $a
    last3=$?
    grep -q ${f2%6}2 $a
    last2=$?
    grep -q ${f2%6}1 $a
    last1=$?
    if [ $last1 -eq 0 ] && [ $last2 -eq 0 ] && [ $last3 -eq 0 ] && [ $last4 -eq 0 ] && [ $last5 -eq 0 ] ; then
      echo $a
    fi
  done
done
