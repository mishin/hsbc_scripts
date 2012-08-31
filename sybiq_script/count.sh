#!/usr/bin/ksh

. /sybiq/SYBASE.sh

tables='
BAIMTHP
BAOMTHP
IE@TNJNP
IRDLIFP
IRDLIXP1
LP@OGHP
SSFXCSP
'
if [ $# -ne 2 ];then
  echo "Usage: $0 table_name 20091010"
  exit 9 
fi

tablename=$1
datestr=$2

case $tablename in 
  all) 
      for i in $tables ;do
        echo "select count(1) from $i where tstimestamp='$datestr'" >$i.$$.sql
        echo "go" >>$i.$$.sql
        conn <$i.$$.sql |head -3 |tail -1|read count
        echo "$i\t\t\t$count"
        rm -f $i.$$.sql
      done
   ;;
  *)
      echo "select count(1) from $tablename where tstimestamp='$datestr' ">$tablename.$$.sql
      echo "go" >>$tablename.$$.sql
      conn< $tablename.$$.sql |head -3 |tail -1|read count
      echo "$tablename\t\t\t$count"
      rm -f $tablename.$$.sql 
  ;;
esac

