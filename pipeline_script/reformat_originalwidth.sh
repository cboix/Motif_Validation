peakfile=$1

sort -u $peakfile|sort -k7gr|awk   'BEGIN{OFS="\t";}{if(NF<3||$3<$2){$3=$2+1};print ".",$1,$2,$3,$5,NR}'|rtool sort  

