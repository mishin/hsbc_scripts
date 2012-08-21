#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

conf=$rootdir/etc/0e.conf
tn=$1

cat $conf |grep "^$tn," |awk -F',' '{print $2" "$4}' |while read coln pre ; do

$VI $rootdir/tmp/$tn.dsx <<EOF
1G/^  *Name "tfpConvert"
/^  *Name "$coln"
ma/^  *Derivation
:s/".*"/"Convert('¥ ','\\\\\\\\',link1.$coln)"\\/
'a/^  *ParsedDerivation
:s/".*"/"Convert('¥ ','\\\\\\\\',link1.$coln)"\\/
o         Transform "\(1B)"
:wq
EOF

done
