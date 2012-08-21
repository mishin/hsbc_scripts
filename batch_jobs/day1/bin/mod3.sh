#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

cat $rootdir/tmp/seqlist |awk '{print $3}' |read fn
fn=$rootdir/tmp/$fn

tn=$1

echo $tn |cut -c1 |read h
cat $rootdir/etc/tmzfld.conf |grep "^$tn " |awk '{print $2}' |read field
if [ "x$field" == "x" ]; then
  field=0
fi

cat $rootdir/tmp/tb.f1 |xargs |sed 's/$/ /' |sed 's/,/,\n/g' |awk '{
if($1~/[#@$]/){
  printf"%s ",$1
  gsub(/[#$@]/,"_",$1)
  printf"%s %s\n",$1,$2
} else
  print$0
}' |awk '{
if($1~/_hex/){
  gsub(/_hex/,")",$1)
  gsub(/^/,"hex(",$1)
}
print
}' >$rootdir/tmp/tb.f1.sql

# alias cannot start with _
cat $rootdir/tmp/tb.f1.sql |awk '{
if($2~/^_/)print $1,$3
else print$0
}' >$rootdir/tmp/tb.f1.sql_
mv -f $rootdir/tmp/tb.f1.sql_ $rootdir/tmp/tb.f1.sql

#mod0e part1
cat $rootdir/etc/0e.$etctype.conf |grep "^$tn," |awk -F',' '{print $2}' |while read coln ; do
  sed -i '/^'"$coln"' /s/^\([^ ]\+\) /hex(\1) /' $rootdir/tmp/tb.f1.sql
done

#modsql
cat $rootdir/etc/sql.$etctype.conf |grep "^$tn " |while read a coln sql ; do
  sed -i '/^'"$coln"' /s/^'"$coln"' /'"$sql"' /' $rootdir/tmp/tb.f1.sql
done

sed -i '/^SELECT/{
n
r'"$rootdir/tmp/tb.f1.sql"'
d
}
/^FROM/{
n
c#prmLibDB2#.#prmTblName#
}
/WHERE/{
n
s/^[^ ]\+ /#prmComment#'"$field"' /
}' $fn

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
  sed -i '/^  *Name "/s/[@#$]/_/g
/DisplaySize/a\
         ParsedDerivation "'"$tn"'.'"$coln"'"\
         SourceColumn "'"$tn"'.'"$coln"'"\
         TableDef "'"$fulltn"'"
/PadChar ""/a\
         ColumnReference "'"$coln"'"' $tmp
  sed -i '/^  *TableDef/s/\\/\\\\/g' $tmp
  #mod0e part2
  cat $rootdir/etc/0e.$etctype.conf |grep "^$tn,$coln," |awk -F',' '{print $4}' |read pre
  if [ "x$pre" != "x" ]; then
    sed -i '/^  *Precision "/s/"[^"]\+"/"'"$((pre*2))"'"/' $tmp
  fi
  cat $tmp >>$summ
done

sed -i '/PANLMMARKHERE/{
r'"$summ"'
d
}' $fn

rm -f $tmp

exit

