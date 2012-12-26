#!/usr/bin/ksh

if [[ $# -ne 1 && $# -ne 2 ]]; then
  echo "usage: $0 ORACLEhub1.csv [file_list]"
  exit 9
fi

csvfile=$1
filelist=$2

img=${csvfile%.*}
img=${img#*ORACLE}

rm -fr $img
mkdir $img 2>/dev/null

# not include tables begin with @
cat $csvfile |grep -v ^\"@ |sed 's/"//g' |awk -F',' '{print $1,$3,$4,$5,$6,$7}' |\
    while read a b c d e f ; do
        echo "$a,$b,$c,$d,$e,$f" >>./$img/"$a"
done

if [ "x$filelist" != "x" ]; then
    mkdir $img.$$
    cat $filelist |xargs -n 1 -t -i{} mv $img/{} $img.$$/ 2>/dev/null
    rm -fr $img
    mv $img.$$ $img
fi
