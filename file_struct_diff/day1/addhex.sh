#!/usr/bin/ksh

if [ $# -ne 2 ];then
  echo "Usage:$0 <hub|tts> log"
  exit
fi
istts=$1
file=$2
if [ ! -f $file ];then
  echo "error:$file is not exist"
  exit
fi

case $istts in
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

cat $file|sed 's/,/ /g'|while read tn coln type len int decimal;do
  case $type in
    A)
       if [ $len -gt 100 ]; then
         sqltype="varchar($((len*2)))"
       else
         sqltype="char($((len*2)))"
       fi
    ;;
    B) sqltype="varbinary(255)"
    ;;
    L) sqltype=date
    ;;
    O) sqltype="varchar(255)"
    ;;
    P|S) if [ $decimal -eq 0 ]; then
           if [ $int -gt 9 ]; then
             sqltype=bigint
           else
             sqltype=int
           fi
         else
           sqltype="decimal($int,$decimal)"
         fi
    ;;
    Z) sqltype=timestamp
    ;;
    T) #sqltype=time
       sqltype=timestamp
    ;;
    esac
  echo "ALTER TABLE $ttshead$tn ADD ${coln}_hex $sqltype NULL"
  echo "go"
  echo "ALTER TABLE $ttshead${tn}_o ADD ${coln}_hex $sqltype NULL"
  echo "go" 
done
