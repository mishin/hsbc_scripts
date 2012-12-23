#!/usr/bin/ksh

cat $1 |grep -q '\*N\.\*FIRST'
if [ $? -eq 0 ]; then
  echo no_member
fi

cat $1 |grep -q "does not have the privilege to perform operation"
if [ $? -eq 0 ]; then
  echo no_privilege
fi

cat $1 |awk '{
if($2~/WARNING/){
  str1=$0
  getline
  if($1~/db2.*sel/||$1~/odbc.*sel/||$1~/db2/){
    str2=$0
    print "datasource_warn"
  }else if($1~/tfpConvert/||$1~/transformer/){
    if($0~/Invalid character conversion found converting to gbk/){
      # ignore (GBK)
      #print "transformer_warn"
    } else {
      print "transformer_warn"
    }
  }else if($1~/fsq.*ort/||$1~/output/) {
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
  if($1~/db2.*sel/||$1~/odbc.*sel/||$1~/db2/){
    str2=$0
    print "datasource_fatal"
  }else if($1~/tfpConvert/||$1~/transformer/){
    if($0~/U_TRUNCATED_CHAR_FOUND/||$0~/Truncated character found/){
    # ignore (truncate)
    #print "truncate"
    } else {
      print "transformer_fatal"
    }
  }else if($1~/fsq.*ort/||$1~/output/) {
    print "output_fatal"
  }else {
    print "other_fatal"
  }
}
}' |sort -u

