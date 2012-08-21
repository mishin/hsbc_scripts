#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -ne 1 ]; then
  exit 9
fi

cat $rootdir/tmp/seqlist |awk '{print $3}' |read fn
fn=$rootdir/tmp/$fn

tn=$1

cat $rootdir/tmp/tb.f1 |xargs |sed 's/$/ /' |sed 's/,/,\n/g' |awk '{
if($1~/[#@$]/){
  printf"\"%s\" ",$1
  gsub(/[#$@]/,"_",$1)
  printf"%s %s\n",$1,$2
} else
  print$0
}' >$rootdir/tmp/tb.f1.sql

sed -i '/^SELECT/{
n
r'"$rootdir/tmp/tb.f1.sql"'
d
}
/^FROM/{
n
c#prmLibDB2#:"'"$tn"'"
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

#$VI +1 $fn <<EOF
#0/      Columns
#jma/      MetaBag
#kd'aOPANLMMARKHERE:wq
#EOF

#$VI +1 $fn <<EOF
#0/         Name "query"
#ma/^SELECT/
#jddk:r $rootdir/tmp/tb.f1.sql
#'a/^FROM
#j0C#prmLibDB2#:"$tn"01G/      Columns
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
  sed -i '/^  *Name "/s/[#@$]/_/g' $tmp
  sed -i '/DisplaySize/a\
         TableDef "'"$fulltn"'"\
         ColumnReference "'"$coln"'"' $tmp
  sed -i '/^  *TableDef/s/\\/\\\\/g' $tmp
  cat $tmp >>$summ
done

sed -i '/PANLMMARKHERE/{
r'"$summ"'
d
}' $fn

#$VI +1 $fn <<EOF
#0/PANLMMARKHERE
#k:r $summ
#/PANLMMARKHERE
#dd:wq
#EOF

rm -f $summ $tmp

exit

# modify colname with #@$
cat $rootdir/tmp/tb.sharp |xargs |read cc
if [ "x" != "x$cc" ]; then
  cat $rootdir/tmp/tb.sharp |while read sharpcol ; do
  $VI +1 $fn <<EOF
0/^  *Name "$sharpcol"
:s/[#@$]/_/g
:wq
EOF
  done
fi


