#!/usr/bin/ksh

type=$1
tn=$2

DB2CODEPAGE=1208;export DB2CODEPAGE
. /home/sds01uc/sds01uc1/sqllib/db2profile
db2 connect to C6SYSTEM user $db2user using $db2pass >/dev/null

case $type in
Date1)  db2 "select ortmz1 from aochubfp.orcdate1 where orflnm = '$tn'" \
          |head -4 |tail -1 |read str
        echo $str |sed 's/[-.]//g' |cut -c1-14
;;
Date2)  db2 "select ordat1 from aochubfp.orcdate2 where orflnm = '$tn'" \
          |head -4 |tail -1 |read str
        echo $str |sed 's/[-.]//g'
;;
esac

db2 disconnect C6SYSTEM >/dev/null

