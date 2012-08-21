#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/demo_job/seqlist |awk '{print $2}' |read fn
fn=$rootdir/demo_job/$fn

tn=$1

echo $tn |cut -c1 |read h

$VI +1 $fn <<EOF
0/^  *Name "USERSQL"/
ma/^SELECT/
jddk:r $rootdir/tmp/tb.f1.sql
'a/^FROM/
jC#prmLibDB2#.$tn/^  *Columns/
jma/^  *MetaBag
kd'aOPANLMMARKHERE:wq
EOF

cat $rootdir/tmp/tb |awk -F'"' '/^  *Identifier/{print$2}' |read fulltn

tmp=$rootdir/tmp/$$
summ=$rootdir/tmp/tb.summ
cp /dev/null $summ
cat $rootdir/tmp/tb.filelist |while read file ; do
cat $rootdir/tmp/$file |awk -F'"' '/^  *Name/{print$2}' |read coln
  cp -f $rootdir/tmp/$file $tmp
  $VI +1 $tmp <<EOF
0/DisplaySize
o         ParsedDerivation "$tn.$coln"
         SourceColumn "$tn.$coln"
         TableDef "$fulltn":s/\\\\/\\\\\\\\/g
/PadChar ""
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

rm -f $tmp

# modify colname with #
cat $rootdir/tmp/tb.sharp |xargs |read cc
if [ "x" != "x$cc" ]; then
  $VI +1 $fn <<EOF
0/^  *Name "USERSQL"
/SELECT
j:s/\\([^ ,][^ ,]*\\)\\([#@$]\\)\\([^ ,]*\\)/\\1\\2\\3 \\1_\\3/g
:wq
EOF

  cat $rootdir/tmp/tb.sharp |while read sharpcol ; do
  $VI +1 $fn <<EOF
0/^  *Name "$sharpcol"
:s/[#@$]/_/g
:wq
EOF
  done
fi


