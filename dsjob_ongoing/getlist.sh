#!/bin/ksh
#
# Set the var
#
if [ $# -ne 2 ];then
  echo "Usage: $0 < hub1 | hub2 | hub3| hub4 | hub5 | tts1 | tts2 | tts3 > <cdc>"
  echo "Example: ./getlist.sh hub1 cdc"
  echo "--------------------"
  cat <<ENDOFTEXT
hub1 : AOC_ORC_HUB_PRD1_SA
hub2 : AOC_ORC_HUB_PRD2_SA
hub3 : AOC_ORC_HUB_PRD3_SA
hub4 : AOC_ORC_HUB_PRD4_SA
hub5 : AOC_ORC_HUB_PRD5_SA
tts1 : AOC_ORC_TTS_PRD1_SA
tts2 : AOC_ORC_TTS_PRD2_SA
tts3 : AOC_ORC_TTS_PRD3_SA
ENDOFTEXT
  exit 9
fi
#
# Init
#
basedir=/hsbc/orc/data/dsjob_ongoing
etcdir=$basedir/etc
hubOrtts=$1
dsOrcdc=$2
timestr=`date +%Y%m%d%H%M%S`
#
# get project and sa Name
#
case $hubOrtts in 
hub1)
  sa=AOC_ORC_HUB_PRD1_SA
  proj=dpr_orc_prd2
;;
hub2)
  sa=AOC_ORC_HUB_PRD2_SA
  proj=dpr_orc_prd2
;;
hub3)
  sa=AOC_ORC_HUB_PRD3_SA
  proj=dpr_orc_prd2
;;
hub4)
  sa=AOC_ORC_HUB_PRD4_SA
  proj=dpr_orc_prd2
;;
hub5)
  sa=AOC_ORC_HUB_PRD5_SA
  proj=dpr_orc_prd2
;;
tts1)
  sa=AOC_ORC_TTS_PRD1_SA
  proj=dpr_orc_prd3
;;
tts2)
  sa=AOC_ORC_TTS_PRD2_SA
  proj=dpr_orc_prd3
;;
tts3)
  sa=AOC_ORC_TTS_PRD3_SA
  proj=dpr_orc_prd3
;;
*)
  echo "Illegal $hubOrtts: not found"
  exit 9
;;
esac
#
# get correct list
#
case $dsOrcdc in 
  cdc)
    if [ -f $etcdir/${sa} ] ;then
      cat $etcdir/$sa | sed "s%^%$proj %" >$basedir/${hubOrtts}cdc.list
    else
      echo "Illegal $sa : The file $etcdir/${sa} does not exist."
      exit 9
    fi
;;
  *)
    echo "Illegal $dsOrcdc : Input cdc "
    exit 9
;;
esac
