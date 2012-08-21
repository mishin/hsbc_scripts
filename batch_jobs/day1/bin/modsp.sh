#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

if [ $tts -eq 1 ]; then
  conf=$rootdir/etc/sp.tts.conf
else
  conf=$rootdir/etc/sp.hub.conf
fi
tn=$1

cat $conf |grep "^$tn " |while read tmp coln fun ; do

echo $coln |sed 's/[@#$]/_/g' |read coln2

$VI $rootdir/tmp/$tn.dsx <<EOF
1G/^  *Name "tfpConvert"
/^  *Name "$coln2"
ma/^  *Derivation
0f"C"$fun"
'a/^  *ParsedDerivation
0f"C"$fun"
:wq
EOF

done

