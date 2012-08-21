#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -ne 1 ]; then
  exit 9
fi

cat $rootdir/tmp/seqlist |awk '{print $4}' |read fn
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

cat $rootdir/tmp/tb |awk -F'"' '/^  *Identifier/{print$2}' |read fulltn
echo $fulltn |sed 's/\\/\\\\\\\\/g' |read fulltn

tmp=$rootdir/tmp/$$
summ=$rootdir/tmp/tb.summ
cp /dev/null $summ
cat $rootdir/tmp/tb.filelist |while read file ; do
  cat $rootdir/tmp/$file |awk -F'"' '/^  *Name/{print$2}' |read coln
  cp -f $rootdir/tmp/$file $tmp
  echo $coln |sed 's/[@#$]/_/g' |read nosharpcoln
  sed -i '/^  *Name/s/[@#$]/_/g
/DisplaySize/a\
         Derivation "lnkFROMdb2TOtfp.'"$nosharpcoln"'"\
         Group "0"\
         ParsedDerivation "lnkFROMdb2TOtfp.'"$nosharpcoln"'"\
         SourceColumn "lnkFROMdb2TOtfp.'"$nosharpcoln"'"\
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
  #mod0e part3
  cat $rootdir/etc/0e.$etctype.conf |grep -q "^$tn,$coln,"
  if [ $? -eq 0 ]; then
    sed -i '/^  *Derivation /s/"\(.*\)"/"StringToUString(xxd(\1), '"'"'935'"'"')"/' $tmp
    sed -i '/^  *ParsedDerivation/s/"\(.*\)"/"StringToUString(xxd(\1), '"'"'935'"'"')"\
         Transform "xxd\\(1B)"/' $tmp
    sed -i '/^  *ExtendedPrecision/s/0/1/' $tmp
  fi
  #mod5b
  cat $rootdir/etc/5b.$etctype.conf |grep -q "^$tn,$coln,"
  if [ $? -eq 0 ]; then
    sed -i '/^  *Derivation /{
s/"/"Convert('"'"''"$yang"' '"'"','"'"'\\\\'"'"',/
s/"[^"]*$/)"/
}' $tmp
    sed -i '/^  *ParsedDerivation /{
s/"/"Convert('"'"''"$yang"' '"'"','"'"'\\\\'"'"',/
s/"[^"]*$/)"\
         Transform "\\(1B)"/
}' $tmp
    cat $tmp |awk '{if($0~/Convert/)gsub("\302\245","\245",$0);print}' >$tmp.1
    mv $tmp.1 $tmp
  fi
  #modsp
  cat $rootdir/etc/sp.$etctype.conf |grep "^$tn $coln " |read a b fun
  if [ "x$fun" != "x" ]; then
    sed -i '/^  *Derivation /c\
         Derivation "'"$fun"'"' $tmp
    sed -i '/^  *ParsedDerivation /c\
         ParsedDerivation "'"$fun"'"' $tmp
  fi
  cat $tmp >>$summ
done

sed -i "/PANLMMARKHERE/r$summ" $fn
sed -i '/PANLMMARKHERE/a\
      BEGIN DSSUBRECORD\
         Name "TSTIMESTAMP"\
         SqlType "1"\
         Precision "26"\
         Scale "0"\
         Nullable "1"\
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

