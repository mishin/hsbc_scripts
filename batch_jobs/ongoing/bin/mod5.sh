#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/tmp/seqlist |awk '{print $5}' |read fn
fn=$rootdir/tmp/$fn

tn=$1

cat $fn |awk '{
if($0~/^      Columns/){
print
getline
while($0!~/^      MetaBag/)getline
print "PANLMMARKHERE"
print
} else {
print
}
}' >$rootdir/tmp/$$
mv -f $rootdir/tmp/$$ $fn

#$VI +1 $fn <<EOF
#0/      Columns
#jma/      MetaBag
#kd'aOPANLMMARKHERE:wq
#EOF

cat $rootdir/tmp/tb |awk -F'"' '/^  *Identifier/{print$2}' |read fulltn
echo $fulltn |sed 's/\\/\\\\\\\\/g' |read fulltn

tmp=$rootdir/tmp/$$
summ=$rootdir/tmp/tb.summ
cp /dev/null $summ
cat $rootdir/tmp/tb.filelist |while read file ; do
  cat $rootdir/tmp/$file |awk -F'"' '/^  *Name/{print$2}' |read coln
  cp -f $rootdir/tmp/$file $tmp
  echo $coln |sed 's/[@#$]/_/g' |read nosharpcoln
  sed -i '/Name/s/[@#$]/_/g
         /DisplaySize/a\
         Derivation "lnkFROModbcTOtfp.'"$nosharpcoln"'"\
         Group "0"\
         ParsedDerivation "lnkFROModbcTOtfp.'"$nosharpcoln"'"\
         SourceColumn "lnkFROModbcTOtfp.'"$nosharpcoln"'"\
         SortKey "0"\
         SortType "0"\
         TableDef "'"$fulltn"'"\
         AllowCRLF "0"\
         PadNulls "0"\
         SortingOrder "0"\
         ArrayHandling "0"\
         ColumnReference "'"$coln"'"\
         PKeyIsCaseless "0"' $tmp
  sed -i '/TableDef/s/\\/\\\\/g' $tmp
  cat $tmp >>$summ
done

sed -i "/PANLMMARKHERE/r$summ" $fn
sed -i '/PANLMMARKHERE/a\
      BEGIN DSSUBRECORD\
         Name "TSTIMESTAMP"\
         SqlType "1"\
         Precision "26"\
         Scale "0"\
         Nullable "0"\
         KeyPosition "0"\
         DisplaySize "0"\
         Derivation "prmDteTimestamp"\
         Group "0"\
         ParsedDerivation "prmDteTimestamp"\
         SortKey "0"\
         SortType "0"\
         AllowCRLF "0"\
         LevelNo "0"\
         Occurs "0"\
         PadNulls "0"\
         SignOption "0"\
         SortingOrder "0"\
         SyncIndicator "0"\
         PadChar ""\
         ExtendedPrecision "0"\
      END DSSUBRECORD' $fn
sed -i '/PANLMMARKHERE/d' $fn

cat $fn |awk '{
if($0~/^  *Name "Schema"/){
print
getline
while($0!~/^=\+=\+=\+=/)getline
} else
print
}' >$rootdir/tmp/$$
mv -f $rootdir/tmp/$$ $fn

rm -f $summ
rm -f $rootdir/tmp/$$

exit

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
         Derivation "prmDteTimestamp"
         Group "0"
         ParsedDerivation "prmDteTimestamp"
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

