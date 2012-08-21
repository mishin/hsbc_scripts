#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

fn=$rootdir/tmp/demopart0.HEAD

tn=$1
echo $tn |sed 's/[@.#]/_/g' |read tn

sed -i '/^  *Identifier/s/".*$/"djpEXTongoing'"$tn"'"/' $fn

exit

$VI +1 $fn <<EOF
0/^  *Identifier
f"lCdjpEXTongoing$tn":wq
EOF


