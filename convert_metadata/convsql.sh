#!/usr/bin/ksh

#tablename/col name/type/length(byte)/precision/floate.decimal/
# A Type A to indicate Character data.               SQL_CHAR 1
# B Type B to indicate Binary data.                  SQL_BINARY -2
# L Type L to indicate Date data.                    SQL_DATE 9
# O Type O to indicate DBCS-Open data.               Unicode string varchar 12
# P Type P to indicate Packed Decimal data.          SQL_DECIMAL 3 (int/bigint/decimal)
# S Type S to indicate Zoned Decimal data.           SQL_DECIMAL 3 (int/bitint/decimal)
# Z Type Z to indicate Time stamp data.              SQL_TIMESTAMP 11
# T ??                                               SQL_TIME 10
# F Type F to indicate Floating Point data.
# H Type H to indicate Hexadecimal data.
# J Type J to indicate DBCS-Only data.
# E Type E to indicate DBCS-Either data.
# G Type G to indicate DBCS-Graphic data.

root=/root/hsbc/script/convert_metadata
if [ ! -d $root ]; then
  echo "$root not exist"
  exit 9
fi

function getnull {
i=0
while [ $i -lt $1 ]; do
echo N
i=$((i+1))
done |xargs |sed 's/ //g'
}

if [ $# -eq 0 ]; then
  echo "usage: $0 [hub|tts] table_name"
  exit 9
fi

type=$1

case $type in
tts)
  #src=$root/treats_add7
  dest=$root/treats_sql
  dest_o=$root/treats_sql_o
  dir=HSBC_treats
  tbhead=TTS_
;;
hub)
  #src=$root/t
  dest=$root/t_sql
  dest_o=$root/t_sql_o
  dir=HSBC
  tbhead=""
;;
*)
  echo "type is error"
  exit 9
;;
esac

#cd $src

  i=$2
  out=$dest/$i.sql
  out_o=$dest_o/$i.sql
  cat >$out <<EOF
CREATE TABLE $tbhead$i (
TSTIMESTAMP timestamp null,
EOF
  cat >$out_o <<EOF
CREATE TABLE $tbhead${i}_o (
TSTIMESTAMP timestamp null,
context char(32) null ,
agent_context char(64) null ,
timestamp char(26) null ,
operation char(12) null ,
tableName char(64) null ,
transactionID char(24) null ,
sequence varchar(20) null ,
journalCode char(1) null ,
entryType char(2) null ,
jobName char(10) null ,
userName char(10) null ,
jobNumber char(6) null ,
programName char(10) null ,
fileName char(10) null ,
libraryName char(10) null ,
memberName char(10) null ,
RRN char(10) null ,
userProfile char(10) null ,
systemName char(8) null ,
referentialConstraint int null ,
trig int null ,
objectNameIndicator char(1) null ,
EOF

  cat "$i" |awk -F',' '{print $2" "$3" "$4" "$5" "$6}' |\
  while read coln type len int decimal ; do
    case $type in
    A) 
       if [ $len -gt 100 ]; then
         sqltype="varchar($len)"
       else
         sqltype="char($len)"
       fi
       scale=0
       null=""
    ;;
    B) sqltype="varbinary(255)"
       extended=0
       precision=$len
       scale=0
       null=""
    ;;
    L) sqltype=date
       extended=0
       precision=$len
       scale=0
       null=""
    ;;
    O) sqltype="varchar(255)"
       extended=1
       #precision=$len
       precision=255
       scale=0
       null=""
    ;;
    P|S) if [ $decimal -eq 0 ]; then
           if [ $int -gt 9 ]; then
             sqltype=bigint
             getnull $((int+2)) |read null
           else
             sqltype=int
             getnull $int |read null
           fi
           extended=0
           precision=$int
           scale=$decimal
         else
           sqltype="decimal($int,$decimal)"
           extended=0
           precision=$int
           scale=$decimal
           getnull $((int+1)) |read null
         fi
    ;;
    Z) sqltype=timestamp
       extended=1
       precision=$len
       scale=0
       null=""
    ;;
    T) #sqltype=time
       sqltype=timestamp
       extended=0
       precision=$len
       scale=0
       null=""
    ;;
    esac

    cat >>$out <<EOF
$coln $sqltype null ,
EOF
    cat >>$out_o <<EOF
$coln $sqltype null ,
EOF
  done

  cat $out |wc -l |read line
  cat $out |sed "$line s/,$//" >$out.1
  mv -f $out.1 $out
  echo ")" >>$out
  echo "go" >>$out

  cat $out_o |wc -l |read line
  cat $out_o |sed "$line s/,$//" >$out_o.1
  mv -f $out_o.1 $out_o
  echo ")" >>$out_o
  echo "go" >>$out_o

  echo "$out created"
  echo "$out_o created"
