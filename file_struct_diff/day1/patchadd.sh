#!/usr/bin/ksh

if [ $# -ne 2 ]; then
  echo "usage: $0 type add_dir_name"
  exit 9
fi

type=$1
src=$2
dest=../${type}_cur

for i in $src/* ; do
cp $dest/${i##*/} $i.bak
cat $i >> $dest/${i##*/}
done

