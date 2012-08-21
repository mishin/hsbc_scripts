#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

function getnull {
i=0
while [ $i -lt $1 ]; do
echo N
i=$((i+1))
done |xargs |sed 's/ //g'
}

tn=$1
cp -f $rootdir/tb/$tn $rootdir/tmp

cd $rootdir/tmp
rm -f $tn.*

cat $tn |awk -F'"' '/^  *Name/ {if($2~/[@#$]/)print$2}' >$tn.sharp

i=1
gethead=0
cat -n $tn |grep -e "BEGIN DSSUBRECORD" -e "END DSSUBRECORD" |awk '{print $1}' |xargs -n 2 |\
while read a b ; do
  if [ $gethead -eq 0 ]; then
    n=$((a-1))
    cat $tn |sed -n "1,$n"p >head
    gethead=1
  fi
  cat $tn |sed -n "$a,$b"p >part$i
  echo part$i >>$tn.filelist
  i=$((i+1))
done

cat $tn.filelist |while read file ; do
  cat $file |awk -F'"' '/Name / {print $2}' |read name
  cat $file |awk -F'"' '/SqlType / {print $2}' |read sqltype
  cat $file |awk -F'"' '/Precision / {print $2}' |read precision
  cat $file |awk -F'"' '/Scale / {print $2}' |read scale
  cat $file |awk -F'"' '/Nullable / {print $2}' |read nullable
  cat $file |awk -F'"' '/KeyPosition / {print $2}' |read keyposition
  cat $file |awk -F'"' '/DisplaySize / {print $2}' |read displaysize
  cat $file |awk -F'"' '/PadChar / {print $2}' |read padchar
  cat $file |awk -F'"' '/APTFieldProp / {print $2}' |read aptfieldprop
  cat $file |awk -F'"' '/ExtendedPrecision / {print $2}' |read extended

  if [ "x" = "x$extended" ]; then
    extended=0
  fi

  #create format1 file
  f1=$tn.f1
  echo "$name, " >>$f1

#  case $sqltype in
#  -10|-9|-8|-4|-3|-2|-1|0|1|9|10|11|12)
#  # string & date & raw type
#    isnum=0
#  ;;
#  -7|-6|-5|2|3|4|5|6|7|8)
#  # integer & decimal & float type
#    isnum=1
#  ;;
#  *)
#    isnum=0
#  ;;
#  esac

  if [ $nullable -eq 1 ];then
    case $sqltype in
    -7|-6|-5|4|5)
      getnull $precision |read null
      aptfield="quote=none, null_field='$null'"
      cat $file |grep -v 'END DSSUBRECORD' |grep -v APTFieldProp >$$
      echo "         APTFieldProp \"$aptfield\"" >>$$
      echo "      END DSSUBRECORD" >>$$
      mv -f $$ $file
    ;;
    2|3|6|7|8)
      if [ $scale -eq 0 ]; then
        getnull $((precision+2)) |read null
      else
        getnull $((precision+1)) |read null
      fi
      aptfield="quote=none, null_field='$null'"
      cat $file |grep -v 'END DSSUBRECORD' |grep -v APTFieldProp >$$
      echo "         APTFieldProp \"$aptfield\"" >>$$
      echo "      END DSSUBRECORD" >>$$
      mv -f $$ $file
    ;;
    esac
  fi

done

#create format1 file
str=`cat $f1 |xargs`
echo "  ${str%,*}" >$f1

rm -f head

cat $tn.filelist |while read p ; do
  cp -f $p $p.1
  mv -f $p $p.2
done

grep -l 'Name "agent_context"' part*.1 |read agc
if [ "x" != "x$agc" ]; then
  $VI +1 $agc <<EOF
/^  *KeyPosition
o         Group "0"
         SortKey "0"
         SortType "0"
         AllowCRLF "0"
         PadNulls "0"
         SortingOrder "0":wq
EOF
fi

