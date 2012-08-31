#!/bin/ksh

if [ $# -ne 1 ];then
 echo "Usage:$0 FileName "
 exit
fi
tablename=$1
filed=$2

cat $1|while read tablename filed;do

 echo "select a.table_name,c.column_name,c.width,d.domain_name \
   from systable a, syscolumn c,sysdomain d \
   where a.table_id=c.table_id and c.domain_id=d.domain_id \
   and a.table_name='$tablename' and c.column_name like '$filed%' ">>$$.sql
 echo "go" >>$$.sql
done


