#!/usr/bin/ksh

. `dirname $0`/env.sh

cd $rootdir/bin 2>/dev/null || exit

#LDACMSP1  SSSECHP2

for i in $rootdir/tb/* ; do
./split.sh
tn=${i##*/}
./convert.sh $tn
./mod0.sh $tn
./mod1.sh $tn
./mod2.sh $tn
./mod3.sh $tn
./mod4.sh $tn
./mod5.sh $tn
./mod6.sh $tn
./mod7.sh $tn
./concatenate.sh $tn
./last.sh $tn
done



