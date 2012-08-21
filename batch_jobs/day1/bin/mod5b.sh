#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

if [ $tts -eq 1 ]; then
  conf=$rootdir/etc/5b.tts.conf
else
  conf=$rootdir/etc/5b.hub.conf
fi
tn=$1
job=$rootdir/tmp/$tn.dsx

#echo 5B |xxd -r -p |uconv -f 935 |read yang
#echo a5 |xxd -r -p |read yang
yang='¥'

cat $conf |grep "^$tn," |awk -F',' '{print $2" "$4}' |while read coln pre ; do

echo $coln |sed 's/[@#$]/_/g' |read coln2

$VI $job <<EOF
1G/^  *Name "tfpConvert"
/^  *Name "$coln2"
ma/^  *Derivation
:s/"/"Convert('$yang ', '\\\\\\\\', /
:s/"[^"]*$/)"/
'a/^  *ParsedDerivation
:s/"/"Convert('$yang ', '\\\\\\\\', /
:s/"[^"]*$/)"/
o         Transform "\(1B)"
:wq
EOF

done

cat $job |awk '{if($0~/Convert/)gsub("\302\245","\245",$0);print}' >$job.$$
mv -f $job.$$ $job

