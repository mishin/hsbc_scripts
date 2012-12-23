#!/usr/bin/ksh

. /sysp/DataStage/Ascential/DataStage/DSEngine/dsenv
export PATH=$DSHOME/bin:/usr/local/bin:$PATH
export rootdir=/hsbc/orc/data/dsjob

#export image
#export image=oraclehub1

#export data dir
export dir=/hsbc/orc/data/alldata

#sybase iq server
export sybhost=130.39.170.7
export sybuser=sybiq
export sybpass=kong1234

#monitor host
#export monhost=133.2.95.85
export monhost=133.2.95.105
export monuser=ftpuser
export monpass=ftpuser
export sftpuser=sftpuser
export sftppass=hsbc@0916

export db2user=AOCRMTSHH
export db2pass=AOCMAR09

export ttsdb2user=AO2RMTAOC
export ttsdb2pass=AOCMAY09
#export ttsdb2user=AOCRMTSHH
#export ttsdb2pass=AOCSEP08

