#!/bin/ksh

. ~/navroot

solution='AOC_ORC_HUB_PRD1_SA
AOC_ORC_HUB_PRD2_SA
AOC_ORC_HUB_PRD3_SA
AOC_ORC_HUB_PRD4_SA
AOC_ORC_HUB_PRD5_SA
AOC_ORC_TTS_PRD1_SA
AOC_ORC_TTS_PRD2_SA
AOC_ORC_TTS_PRD3_SA'

for i in $solution ; do
  cat >$$.sql <<EOF
select last_transaction_timestamp,* from service_context ; 
EOF
  nav_util -b $i execute $i < $$.sql >tmp/$i.out
done

rm -f $$.sql

