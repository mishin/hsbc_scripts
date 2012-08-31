#!/usr/bin/ksh

connstr='ora01ps1@130.37.65.11#9922'

echo $connstr

export PATH=/usr/local/bin:$PATH


ssh "$connstr" ls

