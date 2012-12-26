#!/usr/bin/ksh

if [ $# -ne 4 ]; then
  echo "usage: $0 [hub|tts] [cdc|nocdc] old_ver_dir new_ver_dir"
  exit 9
fi

type=$1
cur=$3
export img=$4
basedir=`dirname $0`

case $type in
tts)
  ttshead="TTS_"
;;
hub)
  ttshead=""
;;
*)
  echo "parameter #1 error"
  exit 9
;;
esac

case $2 in
cdc)
  CONV="$basedir/conv.sh cdc"
  CRTINGLOAD="$basedir/crtingloadcdc.sh"
;;
nocdc)
  CONV="$basedir/conv.sh nocdc"
  CRTINGLOAD="$basedir/crtingload.sh $type"
;;
*)
  echo "parameter #2 error"
  exit 9
;;
esac

cur=`dirname $cur`/`basename $cur`
img=`dirname $img`/`basename $img`

if [[ ! -d $cur || ! -d $img ]]; then
  echo "$cur or $img is not correct"
  exit 9
fi

tmp=/tmp
rm -f $tmp/CREATE

#rm -fr $img.diff 2>/dev/null
rm -fr $img.job 2>/dev/null
rm -fr $img.load 2>/dev/null
rm -fr $img.mod 2>/dev/null
rm -fr $img.add 2>/dev/null

mkdir $img.load 2>/dev/null
mkdir $img.mod 2>/dev/null
mkdir $img.add 2>/dev/null

if [ ! -d "$img.diff" ]; then
  mkdir $img.diff 2>/dev/null
  for i in $img/* ; do
    if [ -f $cur/${i##*/} ]; then
      diff -u $cur/${i##*/} $i >$$
    else
      echo "${i##*/}" >>$tmp/CREATE
      diff -u /dev/null $i >>$$
    fi
    if [ -s $$ ]; then
      mv $$ $img.diff/${i##*/}
    fi
  done
  rm -f $$
fi

ls $img.diff/ |wc -l |read count
if [ $count -eq 0 ]; then
  echo "no file structure diffs found"
  exit 9
fi

if [ ! -d "$img.job" ]; then
  mkdir $img.job 2>/dev/null
  for i in $img.diff/* ; do
    $CONV $img/${i##*/} >$img.job/${i##*/}
  done
  if [ -f $tmp/CREATE ]; then
    cat $tmp/CREATE |while read i ; do
      $CONV $img/${i##*/} >$img.job/${i##*/}
    done
  fi
fi

>$tmp/nodup
>$tmp/dup

# function getnull {{{
function getnull {
:
}
## end function }}}
# function alter {{{
function alter {
case $coltype in
A) 
   if [ $len -gt 100 ]; then
     sqltype="varchar($len)"
   else
     sqltype="char($len)"
   fi
   scale=0
   null=""
;;
B) sqltype="varbinary(255)"
   extended=0
   precision=$len
   scale=0
   null=""
;;
L) sqltype=date
   extended=0
   precision=$len
   scale=0
   null=""
;;
O) sqltype="varchar(255)"
   extended=1
   #precision=$len
   precision=255
   scale=0
   null=""
;;
P|S) if [ $decimal -eq 0 ]; then
       if [ $int -gt 9 ]; then
         sqltype=bigint
         getnull $((int+2)) |read null
       else
         sqltype=int
         getnull $int |read null
       fi
       extended=0
       precision=$int
       scale=$decimal
     else
       sqltype="decimal($int,$decimal)"
       extended=0
       precision=$int
       scale=$decimal
       getnull $((int+1)) |read null
     fi
;;
Z) sqltype=timestamp
   extended=1
   precision=$len
   scale=0
   null=""
;;
T) #sqltype=time
   sqltype=timestamp
   extended=0
   precision=$len
   scale=0
   null=""
;;
esac

altersql=$img.mod/${i##*/}.sql

conf=$basedir/0e.$type.conf
cat $conf |grep -q "^$tn,$coln,"
if [ $? -eq 0 ]; then
  cat >>$altersql <<EOF
ALTER TABLE $ttshead$tn ADD ${coln}_hex $sqltype NULL
go
ALTER TABLE $ttshead${tn}_o ADD ${coln}_hex $sqltype NULL
go
EOF
fi

cat >>$altersql <<EOF
ALTER TABLE $ttshead$tn ADD $coln $sqltype NULL
go
ALTER TABLE $ttshead${tn}_o ADD $coln $sqltype NULL
go
EOF
}
# end function }}}

# create create sql
if [ -f $tmp/CREATE ]; then
  cat $tmp/CREATE |while read j ; do
    $basedir/convsql.sh $type $img/$j >> $img.mod/$j.sql
  done
fi

for i in $img.diff/* ; do

  # 
  altersql=$img.mod/${i##*/}.sql

  # create load sql
  loadsql=$img.load/${i##*/}.sql
  $CRTINGLOAD $img/${i##*/} >$loadsql

  cat $i |sed -n '1,2!p' |sed -n '/^-/p' |awk -F',' '{print ","$2","}' >$tmp/DEL
  cat $i |sed -n '1,2!p' |sed -n '/^+/p' |awk -F',' '{print ","$2","}' >$tmp/ADD
  wc -l $tmp/ADD $tmp/DEL |tail -n 1 |awk '{print $1}' |read tline
  cat $tmp/ADD $tmp/DEL |sort -u |wc -l |read uline
  if [ $tline -eq $uline ]; then
    # no duplicate column
    echo ${i##*/} >>$tmp/nodup

    # create alter sql
    if [ -s $tmp/ADD ]; then
      cat $i |sed -n '1,2!p' |sed -n '/^+/p' |while read line ; do
        echo "$line" |sed 's/^+//' >> $img.add/${i##*/}
        echo "$line" |sed -e 's/,/ /g' -e 's/^+//' -e 's/$//' |read tn coln coltype len int decimal
        #alter
        $basedir/convsql.sh $type $img/$tn $coln >> $altersql
      done
    fi
  else
    # duplicate column
    echo ${i##*/} >>$tmp/dup

    # create alter sql
    if [ -s $tmp/ADD ]; then
      cat $i |sed -n '1,2!p' |sed -n '/^+/p' |grep -vf $tmp/DEL |wc -l |read string
      if [ $string -eq 0 ]; then
        # no add column, only modify and delete
        grep -vf $tmp/ADD $tmp/DEL |read tmpstring
        if [ "x$tmpstring" == "x" ]; then
          # with only changed column (load.sql is no needed)
          rm -f $img.load/${i##*/}.sql
        fi
      else
        cat $i |sed -n '1,2!p' |sed -n '/^+/p' |grep -vf $tmp/DEL |while read line ; do
          echo "$line" |sed 's/^+//' >> $img.add/${i##*/}
          echo "$line" |sed -e 's/,/ /g' -e 's/^+//' -e 's/$//' |read tn coln coltype len int decimal
          #alter
          $basedir/convsql.sh $type $img/$tn $coln >> $altersql
        done
      fi
    fi

    # create alter sql for column modify
    grep -f $tmp/DEL $tmp/ADD |while read dupcoln ; do
      cat $i |sed -n '1,2!p' |sed -n '/^+/p' |grep -f $tmp/ADD |grep $dupcoln |\
        sed -e 's/,/ /g' -e 's/^+//' -e 's/$//' |\
        read addtn addcoln addtype addlen addint adddecimal
      cat $i |sed -n '1,2!p' |sed -n '/^-/p' |grep -f $tmp/DEL |grep $dupcoln |\
        sed -e 's/,/ /g' -e 's/^-//' -e 's/$//' |\
        read deltn delcoln deltype dellen delint deldecimal
      if [ "$addtype" != "$deltype" ]; then
        if [[ $deltype == "O" && $addtype == "A" ]]; then
          # dont care this convert
          echo "# $i $dupcoln change from $deltype to $addtype"
        elif [[ $deltype == "A" && $addtype == "P" ]]; then
          # dont care this convert
          echo "# $i $dupcoln change from $deltype to $addtype"
        else
          echo "$i $dupcoln change from $deltype,$dellen,$delint,$deldecimal to $addtype,$addlen,$addint,$adddecimal"
        fi
      else
        case $addtype in
        A|O)
          if [ $addlen -gt $dellen ]; then
            echo $i $dupcoln $addtype length changed from $dellen to $addlen
          fi
        ;;
        P|S)
          if [[ $addint -ne $delint || $adddecimal -ne $deldecimal ]]; then
            echo $i $dupcoln $addtype length changed from $delint,$deldecimal to $addint,$adddecimal
          fi
        ;;
        *)
          echo $i: $addcoln: $addtype: i cannot convert this type
        ;;
        esac
      fi
    done

  fi

done

# vim:foldmethod=marker:foldenable:foldlevel=0

