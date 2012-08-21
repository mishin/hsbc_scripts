#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/demo_job/seqlist |awk '{print $2}' |read fn
fn=$rootdir/demo_job/$fn

tn=$1

cat $rootdir/tmp/$tn.f1 |sed 's/,/\n, /g' |awk '{if($2~/[#@$]/){printf"%s",$1" \""$2"\" ";gsub(/[#$@]/,"_",$2);printf"%s\n",$2}else print$0}' >$rootdir/tmp/$tn.f1.$$
$VI +1 $fn <<EOF
0/         Name "query"
/^SELECT
jddk:r $rootdir/tmp/$tn.f1.$$
/^FROM
j0C$tn:w
/tablename
f'lcf'$tn':w
01G/      Columns
jma/      MetaBag
kd'aOPANLMMARKHERE:wq
EOF

cat $rootdir/tmp/$tn |awk -F'"' '/^  *Identifier/{print$2}' |read fulltn

tmp=$rootdir/tmp/$$
summ=$rootdir/tmp/$tn.summ
cp /dev/null $summ
cat $rootdir/tmp/$tn.filelist |while read file ; do
cat $rootdir/tmp/$file.1 |awk -F'"' '/^  *Name/{print$2}' |read coln
  cp -f $rootdir/tmp/$file.1 $tmp
  $VI +1 $tmp <<EOF
0/DisplaySize
o         TableDef "$fulltn":s/\\\\/\\\\\\\\/g
o         ColumnReference "$coln":wq
EOF
  cat $tmp >>$summ
done

$VI +1 $fn <<EOF
0/PANLMMARKHERE
k:r $summ
/PANLMMARKHERE
dd:wq
EOF

rm -f $summ $tmp

# modify tablename with #
echo "$tn" |grep -q "@"
if [ $? -eq 0 ]; then
  $VI +1 $fn <<EOF
0/^  *Name "query"
/^FROM
j:s/\\([^ ,][^ ,]*[@][@]*[^ ,][^ ,]*\\)/"\\1"/g
:wq
EOF
fi

# modify colname with #
cat $rootdir/tmp/$tn.sharp |xargs |read cc
if [ "x" != "x$cc" ]; then
#  $VI +1 $fn <<EOF
#0/^  *Name "query"
#/^SELECT
#j:s/,/,/g
#mb?^SELECT
#jma:'a,'b!awk '{if('$2'~/[\\#@$]/){str='$1'" \""'$2'"\" ";gsub(/[\\#$@]/,"_",'$2');print str,'$2'}else print'$0'}'
#
#:wq
#EOF
  cat $rootdir/tmp/$tn.sharp |while read sharpcol ; do
  $VI +1 $fn <<EOF
0/^  *Name "$sharpcol"
:s/[@#$]/_/g
:wq
EOF
  done
fi


