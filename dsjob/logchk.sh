#!/usr/bin/ksh

cat $1 |awk '{
if($2~/WARNING/){
  str1=$0
  getline
  if($1~/db2.*/){
    str2=$0
    print "db2_warn"
  }else if($1~/transformer/||$1~/tfpConvert/){
    if($0~/Invalid character conversion found converting to gbk/){
      # ignore (GBK)
      #print "transformer_warn"
    } else {
      print "transformer_warn"
    }
  }else if($1~/output/||$1~/fsq.*ort/) {
    if($0~/null_field/||$0~/Exporting nullable field without null handling properties/){
      # ignore (NULL)
      #print "output_warn"
    } else if($0~/Invalid character conversion found converting to GBK/){
      # ignore (GBK)
      #print "output_warn"
    } else {
      print "output_warn"
    }
  }else {
    print "other_warn"
  }
}
if($2~/FATAL/){
  str1=$0
  getline
  if($1~/db2.*/){
    str2=$0
    print "db2_fatal"
  }else if($1~/transformer/||$1~/tfpConvert/){
    if($0~/U_TRUNCATED_CHAR_FOUND/||$0~/Truncated character found/){
    # ignore (truncate)
    #print "truncate"
    } else {
      print "transformer_fatal"
    }
  }else if($1~/output/||$1~/fsq.*ort/) {
    print "output_fatal"
  }else {
    print "other_fatal"
  }
}
}' |sort -u

