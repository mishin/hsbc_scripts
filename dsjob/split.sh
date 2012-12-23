#!/usr/bin/ksh
cat a|while read a b;do
  ./splitrun.sh dpr_orc_prd SSFXCSP $a $b
done

