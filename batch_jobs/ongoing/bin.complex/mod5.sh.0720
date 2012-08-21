#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/demo_job/seqlist |awk '{print $5}' |read fn
fn=$rootdir/demo_job/$fn

tn=$1

cat $rootdir/tmp/$tn |awk -F'"' '/^  *Identifier/{print$2}' |read fulltn

$VI +1 $fn <<EOF
0/^  *Name "context"
/^  *TableDef
f"C"$fulltn":s/\\\\/\\\\\\\\/g
/^  *Name "tableName"
/^  *TableDef
f"C"$fulltn":s/\\\\/\\\\\\\\/g
:wq
EOF

