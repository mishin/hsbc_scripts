#!/usr/bin/ksh

cat 4date[12].lst |while read a ; do
  cat hub/$a |awk -F',' '{if($2~/PSDT$/)print$2}' |read str1
  cat hub/$a |awk -F',' '{if($2~/CPDT$/)print$2}' |read str2
  cat hub/$a |awk -F',' '{if($2~/DLUP$/)print$2}' |read str3
  if [[ "x$str1" == "x" && "x$str2" == "x" && "x$str3" == "x" ]]; then
    echo $a >>nodt.lst
    continue
  fi
  #echo $str1 $str2 $str3 |xargs -n 1 |while read coln ; do
  #  echo "select count(*) from oracle0928.$a where $coln = 0" >dtsql/$a.$str1.sql
  #done
  for i in $str1 $str2 $str3 ; do
    echo "select count(*) from oracle0928.$a where $i = 0" >dtsql/$a.$i.sql
  done

done
