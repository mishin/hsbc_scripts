#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -ne 1 ]; then
  exit 9
fi

cat $rootdir/tmp/seqlist |awk '{print $5}' |read fn
fn=$rootdir/tmp/$fn

tn=$1
echo $tn |sed 's/[@.#]/_/g' |read tn

sed -i '/      Name "fsq.*ort/s/fsq.*ort/fsq'"$tn"'ort/' $fn

exit

