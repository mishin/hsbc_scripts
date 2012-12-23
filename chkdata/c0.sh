#!/usr/bin/ksh

if [ $# -ne 1 ]; then
  echo "usage: $0 list_file"
  exit 9
fi

DB2CODEPAGE=1208;export DB2CODEPAGE
. /home/sds01pc/sds01pc1/sqllib/db2profile

passwd_file=/hsbc/orc/data/dsjob/env.sh
. $passwd_file

if [ ! "X$db2user == "X" ] && [ ! "X$db2pass == "X" ];then
  db2 -a connect to C6SYSTEM user $db2user using $db2pass
else
  echo "HUB db2 User or Password Error"
  exit 9
fi

cat $1 |while read a ; do
  db2 -tf $a |awk 'BEGIN {sum=0}
{for(i=1;i<=NF;i++)sum+=$i;if(sum!=0){gsub(/  */," ",$0);print};sum=0}' > ${a%/*}.dat/${a##*/}.out
done

db2 disconnect C6SYSTEM
