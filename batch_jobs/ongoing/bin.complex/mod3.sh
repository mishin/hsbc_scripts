#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/demo_job/seqlist |awk '{print $3}' |read fn
fn=$rootdir/demo_job/$fn

tn=$1

$VI +1 $fn <<EOF
0/^  *Name "Schema"
jma/^=+=+=+=
d'a:wq
EOF


