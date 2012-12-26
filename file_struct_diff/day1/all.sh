#!/usr/bin/ksh

if [[ $# -ne 1 && $# -ne 2 ]]; then
  echo "usage: $0 ORACLEhub1.csv [file_list]"
  exit 9
fi

csvfile=$1
filelist=$2
image_tmp=${csvfile%%.csv}
image=${image_tmp##ORACLE}
case $image in 
hub1|hub2|hub3|hub4|hub5|hub6|hub7|hub8|hub9)
 type=hub
;;
tts1|tts2|tts3|tts4)
 type=tts
;;
*)
 echo "error type"
 exit
;;
esac

echo "Executing ./split.sh $csvfile $filelist ..."
./split.sh $csvfile $filelist
echo "Executing ./crlist.sh $type $image ..."
./crlist.sh $type $image 
echo "Executing ./chkcrt.sh $image ..." 
./chkcrt.sh $image
#echo "Executing tar -cf $image.0e.tar $image.0e ..."
#tar -cf $image.0e.tar $image.0e
#echo "mv $image.0e.tar /tmp ..."
#mv $image.0e.tar /tmp
