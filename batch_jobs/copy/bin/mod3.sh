#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/demo_job/seqlist |awk '{print $3}' |read fn
fn=$rootdir/demo_job/$fn

tn=$1

$VI +1 $fn <<EOF
0/      Columns
jma/      LeftTextPos
kd'aOPANLMMARKHERE:wq
EOF

cat $rootdir/tmp/tb |awk -F'"' '/^  *Identifier/{print$2}' |read fulltn

tmp=$rootdir/tmp/$$
summ=$rootdir/tmp/tb.summ
cp /dev/null $summ
cat $rootdir/tmp/tb.filelist |while read file ; do
  cat $rootdir/tmp/$file |awk -F'"' '/^  *Name/{print$2}' |read coln
  cp -f $rootdir/tmp/$file $tmp
  $VI +1 $tmp <<EOF
0/DisplaySize
o         Derivation "link1.$coln"
         Group "0"
         ParsedDerivation "link1.$coln"
         SourceColumn "link1.$coln"
         SortKey "0"
         SortType "0"
         TableDef "$fulltn":s/\\\\/\\\\\\\\/g
o         AllowCRLF "0"
         PadNulls "0"
         SortingOrder "0"
         ArrayHandling "0"
         ColumnReference "$coln"
         PKeyIsCaseless "0":wq
EOF
  cat $tmp >>$summ
done

$VI +1 $fn <<EOF
0/PANLMMARKHERE
k:r $summ
/PANLMMARKHERE
dd:wq
EOF

rm -f $summ
rm -f $rootdir/tmp/$$

# modify colname with #
cat $rootdir/tmp/tb.sharp |xargs |read cc
if [ "x" != "x$cc" ]; then
  cat $rootdir/tmp/tb.sharp |while read sharpcol ; do
  echo "$sharpcol" |sed 's/[@#$]/_/g' |read nosharpcol
  $VI +1 $fn <<EOF
0/^  *Name "$sharpcol"
ma/^  *ColumnReference
k:'a,.s/$sharpcol"/$nosharpcol"/
:wq
EOF
  done
fi




