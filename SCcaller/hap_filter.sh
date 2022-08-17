#!/bin/bash
id=$1
bulk=$2

#echo "/Jan-Lab/zhengchen/nfscore/$id/results/VariantCalling/$bulk/HaplotypeCaller/HaplotypeCaller_$bulk.vcf"

inputvcf="/Jan-Lab/zhengchen/nfscore/$id/results/VariantCalling/$bulk/HaplotypeCaller/HaplotypeCaller_$bulk.vcf"
annvcf="/Jan-Lab/zhengchen/nfscore/$id/results/VariantCalling/$bulk/HaplotypeCaller/$bulk.vcf"
outputvcf="/Jan-Lab/zhengchen/nfscore/$id/results/VariantCalling/$bulk/HaplotypeCaller/filter_HaplotypeCaller_$bulk.vcf"

echo -e  "$inputvcf\n$outputvcf\n$annvcf"

gatk VariantFiltration -V $inputvcf -O $annvcf  --filter-expression "DP < 20 || QUAL < 30.0" --filter-name "DP20_QUAL30"
grep -v "rs" $annvcf |grep -v "DP20_QUAL30" > $outputvcf

