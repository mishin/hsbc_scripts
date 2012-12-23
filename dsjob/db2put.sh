#!/usr/bin/ksh

type=$1
tn=$2
str=$3
str1=$4

DB2CODEPAGE=1208;export DB2CODEPAGE
. /home/sds01uc/sds01uc1/sqllib/db2profile
db2 -a connect to C6SYSTEM user $db2user using $db2pass >/dev/null

case $type in
Date1)
    db2 "update aochubfp.orcdate1 set ortmz1 = '$str' where orflnm = '$tn'" >/dev/null
;;
Date2)
    db2 "update aochubfp.orcdate2 set ordat1 = '$str' where orflnm = '$tn'" >/dev/null
;;
Ongoing)
    db2 "insert into aochubfp.orcdate3 (orflnm,orcutof,orcont) values ('$tn','$str','$str1') " >/dev/null
;;
esac

db2 disconnect C6SYSTEM >/dev/null

