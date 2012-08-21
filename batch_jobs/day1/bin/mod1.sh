#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -ne 1 ]; then
  exit 9
fi

cat $rootdir/tmp/seqlist |awk '{print $1}' |read fn
fn=$rootdir/tmp/$fn

tn=$1
tnorig=$1
echo $tn |cut -c1 |read h
echo $tn |sed 's/[@.#]/_/g' |read tn

# in day1 lib means library
if [ $tts -eq 1 ]; then
  lib=oracletts1
else
  lib=oraclehub1
fi

if [ "$tbtype" == "day1" ]; then
  prefix=""
else
  prefix="ongoing_"
fi

sed -i '/^  *Prompt "tablename"/{
n
s/".*$/"'"$tnorig"'"/
}' $fn

sed -i '/^  *Prompt "filename"/{
n
s/".*$/"'"$tn"'.TXT"/
}
/      OrchestrateCode =+=+=+=/,/^=+=+=+=/d' $fn
sed -i '/^      Name/s/".*$/"djpEXT'"$tbtype$tn"'"/' $fn
sed -i '/^      Category/s/".*$/"orc\\\\extracts\\\\'"$prefix$tbtype"'\\\\'"$h"'"/' $fn

exit

