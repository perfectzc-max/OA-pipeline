#!/bin/bash
P=$1
cell=$2
bulk=$3

#list vcf file of bulk
ls /Jan-Lab/zhengchen/nfscore/P*/results/VariantCalling/*/HaplotypeCaller/HaplotypeCaller_*B.vcf |awk -F "/" '{print $8 }' >bulk.txt

#step 1
#filter out rows without IDS, filter out non-heterozygous sites, filter out those without passes
#filter out depth < 20x
for i in $(cat bulk.txt);do echo "nohup sh 1_vcf_collect.sh $i &" ;done |bash

#step2 3 parameter
#Calculate the overlap area of bulk and cell
for i in $(seq 1 23)  ; do echo "\
nohup sh 2_cov_sen.v2.hg19.sh \
$i \
${P} \
/Jan-Lab/zhengchen/nfscore/${P}/*/Preprocessing/${bulk}/Recalibrated ${bulk} \
/Jan-Lab/zhengchen/nfscore/${P}/*/Preprocessing/${cell}/Recalibrated ${cell} &\
" ;done | bash

#step3 two parameter
#caculate coverage
#SNV 1-22, SNV X, INDEL 1-22, INDEL X
sh 3_cal_cov.sh ${P} ${cell}

#step 4 two parameter
#caculate sensitivity
#observed hsnp, missing hsnp: SNV 1-22, SNV X, INDEL 1-22, INDEL X
sh 4_sen_q25.sh ${P} ${cell}

#check result
cat  /Jan-Lab/zhengchen/correct_cov/cov_sen/P*/*.sen>sen.txt
cat  /Jan-Lab/zhengchen/correct_cov/cov_sen/P*/*.cov >cov.txt
