#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/tmp/seqlist |awk '{print $6}' |read fn
fn=$rootdir/tmp/$fn

tn=$1
echo $tn |sed 's/[@.#]/_/g' |read tn

sed -i '/      Name "fsq.*ort/s/fsq.*ort/fsq'"$tn"'ort/' $fn

exit

