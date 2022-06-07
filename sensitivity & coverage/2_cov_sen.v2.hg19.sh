#!/bin/bash
echo "start on"; date; echo "====="
chr=$1
x=$(sed -n "$chr p" hs.config.hg19.txt)
P=$2
bulk_path=$3
cell_path=$5
bulk=$4
cell=$6

echo "$P,${bulk_path},${cell_path},${x},${bulk},${cell}"

mkdir -p /Jan-Lab/zhengchen/correct_cov/cov_sen/${P}/cov/INDEL/${cell}
mkdir -p /Jan-Lab/zhengchen/correct_cov/cov_sen/${P}/cov/SNV/${cell}
mkdir -p /Jan-Lab/zhengchen/correct_cov/cov_sen/${P}/sen/SNV/${cell}
mkdir -p /Jan-Lab/zhengchen/correct_cov/cov_sen/${P}/sen/INDEL/${cell}

perl /Jan-Lab/zhengchen/correct_cov/pipline/2_cov_sen.v2.hg19.pl  -g ${P} -p ${cell_path} -b ${bulk} -c ${cell} -d ${bulk_path} -r ${x}


echo "end on"; date; echo "====="

