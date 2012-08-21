#!/usr/bin/ksh

all=all.dsx

cat -n $all |grep -e 'BEGIN DSRECORD' -e 'END DSRECORD' |awk '{print $1}' |\
xargs -n 2 |while read a b ; do
  cat $all |sed -n "$a,$b"p |awk -F'"' '/^  *Identifier/{print$2}' |read fulltn
  echo ${fulltn##*\\} |read tn
  cat $all |sed -n "$a,$b"p >$tn
done


