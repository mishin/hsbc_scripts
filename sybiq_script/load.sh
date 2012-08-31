#!/usr/bin/ksh

if [ $# -ne 2 ]; then
    echo
    echo "Usage: $0 [ day1 | ongoing | ondate ] datafile_name"
    echo "       $0 [ ttsday1 | ttsongoing | ttsondate ] datafile_name"
    echo
    exit 9
fi

. /sybiq/SYBASE.sh

type=$1
rootdir=/sybiq/script
workdir=$rootdir/work
tmpdir=/sybiq/tmp/load
datadir=$rootdir/data_$type
loaddir=$rootdir/load_$type
donedir=$rootdir/done_$type
faildir=$rootdir/fail_$type

sendmesg=/sybiq/script/FFMessage/sendmesg.sh

ls $datadir/$2 >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
    echo "no files in data_$type"
    exit
fi

i=$2
filename=${i##*/}
filename=${filename%.*}
echo $filename |awk -F'.' '{print $1" "$2}' |read tablename timestamp

mv $datadir/$filename.TXT $workdir/$filename.TXT.orig

### drop ^@ string
### using to other filesystem
sed -n '1,$p' $workdir/$filename.TXT.orig > $tmpdir/$filename.TXT

cat $loaddir/$tablename.sql 2>/dev/null |expand >$workdir/$filename.sql
echo "set option public.conversion_error='off';" >$workdir/$$.sql
awk 'END {print NR}' $workdir/$filename.sql |read linenum
delimitstr="#!#"
head -1 $workdir/$filename.sql >>$workdir/$$.sql
cat >>$workdir/$$.sql <<EOF
TSTIMESTAMP '$delimitstr',
EOF
cat $workdir/$filename.sql |sed -n "2,$((linenum-1))"p |sed -e "s/|/$delimitstr/" -e 's/\\x0a/#!\
/' >>$workdir/$$.sql
mv -f $workdir/$$.sql $workdir/$filename.sql

case $type in
day1)
    :
;;
ongoing)
    cat $workdir/$filename.sql |sed '4,25s/null ,$/,/' >$workdir/$$.sql
    mv -f $workdir/$$.sql $workdir/$filename.sql
;;
ondate)
    cat $workdir/$filename.sql |sed '/[Ll][Oo][Aa][Dd]  *[Tt][Aa][Bb][Ll][Ee]/s/\([^ ][^ ]*\)\(  *(\)/\1_o\2/' >$workdir/$$.sql
    mv -f $workdir/$$.sql $workdir/$filename.sql
;;
ttsday1)
    cat $workdir/$filename.sql |sed '/[Ll][Oo][Aa][Dd]  *[Tt][Aa][Bb][Ll][Ee]/s/\([^ ][^ ]*\)\(  *(\)/TTS_\1\2/' >$workdir/$$.sql
    mv -f $workdir/$$.sql $workdir/$filename.sql
;;
ttsongoing)
    cat $workdir/$filename.sql |sed '4,25s/null ,$/,/' >$workdir/$$.sql
    mv -f $workdir/$$.sql $workdir/$filename.sql
    cat $workdir/$filename.sql |sed '/[Ll][Oo][Aa][Dd]  *[Tt][Aa][Bb][Ll][Ee]/s/\([^ ][^ ]*\)\(  *(\)/TTS_\1\2/' >$workdir/$$.sql
    mv -f $workdir/$$.sql $workdir/$filename.sql
;;
ttsondate)
    cat $workdir/$filename.sql |sed '/[Ll][Oo][Aa][Dd]  *[Tt][Aa][Bb][Ll][Ee]/s/\([^ ][^ ]*\)\(  *(\)/TTS_\1_o\2/' >$workdir/$$.sql
    mv -f $workdir/$$.sql $workdir/$filename.sql
;;
esac

cat >>$workdir/$filename.sql <<EOF
from '$workdir/$filename.TXT'
escapes off
quotes off
strip on
-- IGNORE CONSTRAINT ALL 0
MESSAGE LOG '$workdir/$filename.msg.log' ROW LOG '$workdir/$filename.row.log' ONLY LOG ALL
LOG DELIMITED BY '#!#'
go
EOF

### solve ting problem
### delete half of ting and dont change unix return to a dos return
### using from other filesystem
awk '{gsub("\302\043\041","\043\041",$0)
if($0~/$/){
    gsub("","",$0)
    printf"%s\r\n",$0
} else
print $0
}' $tmpdir/$filename.TXT >$workdir/$$.TXT
mv $workdir/$$.TXT $workdir/$filename.TXT
rm -f $tmpdir/$filename.TXT

### @ in columns
cat $workdir/$filename.sql |grep -q "^@"
if [ $? -eq 0 ]; then
    cat $workdir/$filename.sql |sed 's/^\(@[^ ][^ ]*\) /[\1] /' >$workdir/$$.sql
    mv -f $workdir/$$.sql $workdir/$filename.sql
fi

### load
isql -U hsbc -P hsbc -S hsbcdw -D hsbcdw -o $workdir/$filename.out -i $workdir/$filename.sql

cat $workdir/$filename.out |grep affected |sed 's/[()]//g' |read c d
if [ "x$c" = "x" ]; then
    c=0
fi
if [ $c -ne 0 ]; then
    echo "${i},successful,$c"
    rm -f $workdir/$filename.TXT 2>/dev/null
    #mv $workdir/$filename.TXT.orig $donedir 2>/dev/null
    #mv $workdir/$filename.sql $donedir 2>/dev/null
    # backup the data file & sql
    $rootdir/backup.sh $type $workdir/$filename.TXT.orig 
    mv $workdir/$filename.msg.log $donedir 2>/dev/null
    mv $workdir/$filename.row.log $donedir 2>/dev/null
    mv $workdir/$filename.out $donedir 2>/dev/null
else
    echo "${i},failed,$c"
    if [ $type != "day1" ] && [ $type != "ttsday1" ] && [ `date +%H` -ge 8 ] && [ `date +%H` -le 19 ];then
      :
      logger -t root "ORC2002X : LOAD ERROR,$type,${i},failed "
    fi
    $sendmesg "ORC2002X : LOAD ERROR,$type,${i},failed "
    mv $workdir/$filename.TXT* $faildir 2>/dev/null
    mv $workdir/$filename.sql $faildir 2>/dev/null
    mv $workdir/$filename.msg.log $faildir 2>/dev/null
    mv $workdir/$filename.row.log $faildir 2>/dev/null
    mv $workdir/$filename.out $faildir 2>/dev/null
fi

