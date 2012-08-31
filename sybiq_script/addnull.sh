#!/bin/ksh

cd create_o
for i in *.sql ; do
cat $i |sed -n '1,23p' >$i.new
cat $i |sed -n '24p' |sed 's/,$/null ,/' >>$i.new
cat $i |sed -n '25,$p' >>$i.new
mv $i.new $i
done
