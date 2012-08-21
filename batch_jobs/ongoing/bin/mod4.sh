#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/tmp/seqlist |awk '{print $4}' |read fn
fn=$rootdir/tmp/$fn

tn=$1

cat $fn |awk '{
if($0~/^  *Name "Schema"/){
print
getline
while($0!~/^=\+=\+=\+=/)getline
} else
print
}' >$rootdir/tmp/$$
mv -f $rootdir/tmp/$$ $fn

exit

$VI +1 $fn <<EOF
0/^  *Name "Schema"
jma/^=+=+=+=
d'a:wq
EOF

