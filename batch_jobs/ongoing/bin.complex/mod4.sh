#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/demo_job/seqlist |awk '{print $4}' |read fn
fn=$rootdir/demo_job/$fn

tn=$1

$VI +1 $fn <<EOF
0/      Columns
jma/      MetaBag
kd'aOPANLMMARKHERE:wq
EOF

cat $rootdir/tmp/$tn |awk -F'"' '/^  *Identifier/{print$2}' |read fulltn

tmp=$rootdir/tmp/$$
summ=$rootdir/tmp/$tn.summ
cp /dev/null $summ
cat $rootdir/tmp/$tn.filelist |while read file ; do
  cat $rootdir/tmp/$file.2 |awk -F'"' '/^  *Name/{print$2}' |read coln
  cp -f $rootdir/tmp/$file.2 $tmp
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
ko      BEGIN DSSUBRECORD
         Name "TSTIMESTAMP"
         SqlType "1"
         Precision "26"
         Scale "0"
         Nullable "0"
         KeyPosition "0"
         DisplaySize "0"
         Derivation "tstimestamp"
         Group "0"
         ParsedDerivation "tstimestamp"
         SortKey "0"
         SortType "0"
         AllowCRLF "0"
         LevelNo "0"
         Occurs "0"
         PadNulls "0"
         SignOption "0"
         SortingOrder "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
      END DSSUBRECORD:r $summ
/PANLMMARKHERE
dd/^  *Name "Schema"
jma/^=+=+=+=
d'a:wq
EOF

rm -f $summ
rm -f $rootdir/tmp/$$

# modify colname with #
cat $rootdir/tmp/$tn.sharp |xargs |read cc
if [ "x" != "x$cc" ]; then
  cat $rootdir/tmp/$tn.sharp |while read sharpcol ; do
  echo "$sharpcol" |sed 's/[@#$]/_/g' |read nosharpcol
  $VI +1 $fn <<EOF
0/^  *Name "$sharpcol"
ma/^  *ColumnReference
k:'a,.s/$sharpcol"/$nosharpcol"/
:wq
EOF
  done
fi




