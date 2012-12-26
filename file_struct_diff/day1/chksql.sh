#!/usr/bin/ksh
if [ $# -ne 2 ];then
 echo "Usage:$0 <hub|tts> <file>"
 exit
fi
type=$1
file=$2
case $type in 
hub) head=""
;;
tts) head="TTS_"
;;
*)
    echo "error: $type" 
    exit
;;
esac

cat $file|awk -F',' '{print$1" "$2}'|while read tablename column;do
   tablename=${tablename##*/}
   echo "select a.table_name,c.column_name,d.domain_name,c.width \
from systable a, syscolumn c,sysdomain d \
where a.table_id=c.table_id and c.domain_id=d.domain_id \
and a.table_name='$head$tablename' \
and c.column_name like '$column%' "
done
