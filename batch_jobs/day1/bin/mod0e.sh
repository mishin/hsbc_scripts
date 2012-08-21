#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

if [ $tts -eq 1 ]; then
  conf=$rootdir/etc/0e.tts.conf
else
  conf=$rootdir/etc/0e.hub.conf
fi
tn=$1

cat $conf |grep "^$tn," |awk -F',' '{print $2" "$4}' |while read coln pre ; do

echo $coln |sed 's/[@#$]/_/g' |read coln2

$VI $rootdir/tmp/$tn.dsx <<EOF
1G/^SELECT
ma/^FROM
mb:'a,'bs/^$coln /hex($coln) /

1G/^  *Name "lnkFROMdb2TOtfp"
/^  *Name "$coln2"
/^  *Precision
:s/$pre/$((pre*2))/

1G/^  *Name "tfpConvert"
/^  *Name "$coln2"
ma/^  *Derivation
0f"lCStringToUString(xxd(lnkFROMdb2TOtfp.$coln2), '935')"
'a/^  *ParsedDerivation
0f"lCStringToUString(xxd(lnkFROMdb2TOtfp.$coln2), '935')"
         Transform "xxd\(1B)"
'a/^  *ExtendedPrecision
:s/0/1/
:wq
EOF

done
