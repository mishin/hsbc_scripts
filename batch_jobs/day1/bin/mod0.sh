#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -ne 1 ]; then
  exit 9
fi

fn=$rootdir/tmp/demopart0.HEAD

tn=$1
echo $tn |sed 's/[@.#]/_/g' |read tn

sed -i '/^  *Identifier/s/".*$/"djpEXT'"$tbtype$tn"'"/' $fn

exit

