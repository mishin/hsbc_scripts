#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

tn=$1
echo $tn |cut -c1 |read h
job=$rootdir/job/$tn.dsx
$VI +1 $job <<EOF
0/  *Identifier
:s/SAT_Ongoing_Routine_DEMOJOB/$tn/
/  *Name
:s/SAT_Ongoing_Routine_DEMOJOB/$tn/
/  *Category
0:s/DEMOJOB/HSBC\\\\\\\\$h/
:wq
EOF


