#!/bin/ksh

cd tmp

for i in * ; do

cat "$i" |awk '/^  *BEGIN DSSUBRECORD/,/^  *END DSSUBRECORD/{
if($0~/^  *Name/){gsub("\"","",$2);printf"%s ",$2};
if($0~/^  *APTFieldProp/){gsub("\"","",$3);print$3}}' |while read a b ; do

b=${b##*=}
if [ "$b" == "''" ]; then
str=","
else
str="NULL($b),"
fi

echo $a "'|'" $str


done >"${i%.*}.sql.new"

wc -l "${i%.*}.sql.new" |read count tmp

cat "../load_ongoing/${i%.*}.sql" |sed -n '1p' >"${i%.*}.sql.new.1"
cat "../load_ongoing/${i%.*}.sql" |sed -n '2,23p' |sed 's/,$/ null ,/' >>"${i%.*}.sql.new.1"
cat "${i%.*}.sql.new" |sed -n "1,$((count-1))"p >> "${i%.*}.sql.new.1"
cat "${i%.*}.sql.new" |tail -1 |sed 's/|/\\x0a/' |sed 's/,$/)/' >>"${i%.*}.sql.new.1"
echo "FROM '{tablename}'" >>"${i%.*}.sql.new.1"

mv "../load_ongoing/${i%.*}.sql" "../load_ongoing/${i%.*}.sql.orig"
mv "${i%.*}.sql.new.1" "../load_ongoing/${i%.*}.sql"

done


