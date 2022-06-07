P=$1
samplename=$2
cd /Jan-Lab/zhengchen/correct_cov/cov_sen/$P/cov/
a=`awk 'BEGIN{summ=0}{summ=summ+$3-$2+1}END{print summ}' SNV/$samplename/$samplename.[0-9]*.bed`
b=`awk 'BEGIN{summ=0}{summ=summ+$3-$2+1}END{print summ}' SNV/$samplename/$samplename.X.bed`
c=`awk 'BEGIN{summ=0}{summ=summ+$3-$2+1}END{print summ}' INDEL/$samplename/$samplename.[0-9]*.bed`
d=`awk 'BEGIN{summ=0}{summ=summ+$3-$2+1}END{print summ}' INDEL/$samplename/$samplename.X.bed`
echo cov ${samplename} $a $b $c $d > /Jan-Lab/zhengchen/correct_cov/cov_sen/$P/$samplename.cov
