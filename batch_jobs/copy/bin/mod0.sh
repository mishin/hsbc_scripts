#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

fn=$rootdir/demo_job/part0.HEAD

tn=$1
echo $tn |sed 's/[@.#]/_/g' |read tn

$VI +1 $fn <<EOF
0/^  *Identifier
f"lCdjpEXTday1$tn":wq
EOF
