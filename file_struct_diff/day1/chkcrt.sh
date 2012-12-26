#!/usr/bin/ksh

if [ $# -ne 1 ]; then
  echo "$0 hub1"
  exit 9
fi

img=$1
rm -fr $img.0e
#rm -fr $img.5b
mkdir $img.0e 2>/dev/null
#mkdir $img.5b 2>/dev/null

# create check 0e sql
for i in $img/* ; do
  ./cr0e.sh $i |tee $img.0e/${i##*/}.sql |wc -l |read line
  if [ $line -eq 2 ]; then
    sed -i "/select/s/$/ '0' as col /" $img.0e/${i##*/}.sql
  fi
done

# create check 5b sql
#for i in $img/* ; do
#  ./cr5b.sh $i >$img.5b/${i##*/}.sql
#done



