#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/demo_job/seqlist |awk '{print $1}' |read fn
fn=$rootdir/demo_job/$fn

tn=$1
echo $tn |cut -c1 |read h
echo $tn |sed 's/[@.#]/_/g' |read tn

# in day1 lib means library
if [ $tts -eq 1 ]; then
  lib=`cat $rootdir/etc/tts |grep ",${tn}," |awk -F',' '{print $1}'`
  if [ "x" == "x$lib" ]; then
    lib=UNKNOWNLIB
  fi 
else
  lib=AOCHUBFP
fi

$VI +1 $fn <<EOF
0/^  *Prompt "directoryname"
jf"lC$filepath"/^  *Prompt "filename"
jf"lC$tn.TXT"/^  *Prompt "libraryname"
jf"lC$lib"/      OrchestrateCode =+=+=+=
ma/^=+=+=+=/
d'a1G/^  *Name
f"lCdjpEXTday1$tn"/^  *Category
f"lCorc\\\\extracts\\\\day1\\\\$h":wq
EOF
