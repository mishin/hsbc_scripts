#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/demo_job/seqlist |awk '{print $1}' |read fn
fn=$rootdir/demo_job/$fn

tn=$1
echo ${tn#*.} |cut -c1 |read h

# in ongoing lib means solution
if [ $tts -eq 1 ]; then
  lib=`cat $rootdir/etc/tts |grep ",${tn}," |awk -F',' '{print $4}'`
  if [ "x" == "x$lib" ]; then
    lib=UNKNOWNLIB
  fi 
else
  grep -l "$tn" $rootdir/etc/AOC_ORACLE_TEST*_SA |read lib
  lib=${lib##*/}
fi

echo $tn |sed 's/[@.#]/_/g' |read tn
$VI +1 $fn <<EOF
0/^  *Prompt "directory"
jf"lC$filepath"/^  *Prompt "filename"
jf"lC${tn}_o.TXT"/^  *Prompt "library"
jf"lC$lib"/      OrchestrateCode =+=+=+=
ma/^=+=+=+=/
d'a1G/^  *Name
f"lCOngoing_$tn"/^  *Category
f"lCHSBC\\\\Ongoing\\\\$h":wq
EOF

