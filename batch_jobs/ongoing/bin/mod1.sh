#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/tmp/seqlist |awk '{print $1}' |read fn
fn=$rootdir/tmp/$fn

tn=$1
echo ${tn#*.} |cut -c1 |read h
echo $tn |sed 's/[@.#]/_/g' |read tn

# in ongoing lib means solution
if [ $tts -eq 1 ]; then
  lib=AOC_ORACLE_TTS_SA
else
  lib=AOC_ORACLE_HUB_SA
fi

sed -i '/^  *Prompt "filename"/{n;s/".*$/"'"$tn"'.TXT"/}
/      OrchestrateCode =+=+=+=/,/^=+=+=+=/d' $fn
sed -i '/^      Name/s/".*$/"djpEXTongoing'"$tn"'"/' $fn
sed -i '/^      Category/s/".*$/"orc\\\\extracts\\\\ongoing\\\\'"$h"'"/' $fn

exit

$VI +1 $fn <<EOF
0/^  *Prompt "filename"
jf"lC${tn}.TXT"/      OrchestrateCode =+=+=+=
ma/^=+=+=+=/
d'a1G/^  *Name
f"lCdjpEXTongoing${tn}"/^  *Category
f"lCorc\\\\extracts\\\\ongoing\\\\$h":wq
EOF

