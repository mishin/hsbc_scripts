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


function getnull { #{{{
i=0
while [ $i -lt $1 ]; do
echo N
i=$((i+1))
done |xargs |sed 's/ //g'
} #}}}

function func1 { #{{{
  case $coltype in
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
     precision=$len
     #precision=255
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
} #}}}

if [[ $# -ne 2 && $# -ne 3 ]]; then
  echo "usage: $0 [hub|tts] table_name [column_name]"
  exit 9
fi

type=$1
column_name=$3
basedir=`dirname $0`
conf=$basedir/0e.$type.conf
tmpdir=/tmp

case $type in
tts)
  tbhead=TTS_
;;
hub)
  tbhead=""
;;
*)
  echo "type is error"
  exit 9
;;
esac

filename=$2
tn=`basename $filename`

if [ ! -f $filename ]; then
  echo "$filename not found"
  exit 9
fi

cat $conf |grep -q "^$tn,"
if [ $? -eq 0 ]; then
  $basedir/0e.sh $type $filename >$tmpdir/$$
  filename=$tmpdir/$$
fi

if [ "x$column_name" == "x" ]; then

  # init $out $out_o {{{
  out=$tmpdir/$$.1
  out_o=$tmpdir/$$.2
  cat >$out <<EOF
CREATE TABLE $tbhead$tn (
TSTIMESTAMP timestamp null,
EOF
  cat >$out_o <<EOF
CREATE TABLE $tbhead${tn}_o (
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
  #}}}

  cat "$filename" |dos2unix |awk -F',' '{print $2" "$3" "$4" "$5" "$6}' |\
  while read coln coltype len int decimal ; do
    func1
    cat >>$out <<EOF
$coln $sqltype null ,
EOF
    cat >>$out_o <<EOF
$coln $sqltype null ,
EOF
  done

  cat $out |wc -l |read line
  cat $out |sed "$line s/,$//" >$tmpdir/$$
  mv -f $tmpdir/$$ $out
  echo ")" >>$out
  echo "go" >>$out
  
  cat $out_o |wc -l |read line
  cat $out_o |sed "$line s/,$//" >$tmpdir/$$
  mv -f $tmpdir/$$ $out_o
  echo ")" >>$out_o
  echo "go" >>$out_o

  cat $out
  cat $out_o

else

  # init $altout {{{
  altout=$tmpdir/$$.3
  cat >$altout <<EOF
EOF
  #}}}

  cat "$filename" |dos2unix |grep ",${column_name}[,_]" |awk -F',' '{print $2" "$3" "$4" "$5" "$6}' |\
  while read coln coltype len int decimal ; do
    func1
    cat >>$altout <<EOF
ALTER TABLE $tbhead$tn ADD $coln $sqltype NULL
go
ALTER TABLE $tbhead${tn}_o ADD $coln $sqltype NULL
go
EOF
  done

  cat $altout

fi

rm -f $out $out_o $altout $tmpdir/$$

# vim:foldmethod=marker:foldenable:foldlevel=0
