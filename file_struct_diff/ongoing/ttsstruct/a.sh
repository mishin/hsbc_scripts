#!/bin/bash

cat all |awk -F',' '{printf"%s %s,%s,%s,%s,%s,%s\n",$1,$1,$3,$4,$5,$6,$7}' |\
  while read a b ; do
  echo "$b" >>tts/$a
done

cd tts

echo "delete these files manually"
ls [#@]*
ls *[#@]
ls TOFTPCP TTCDCD0001 TTCDCDP


