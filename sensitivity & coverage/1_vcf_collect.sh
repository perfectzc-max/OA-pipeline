#!/bin/bash

samplename=$1

awk '$3!="." && substr($10,1,3)=="0/1" && $7=="."' /Jan-Lab/zhengchen/nfscore/P*/results/VariantCalling/${samplename}/HaplotypeCaller/HaplotypeCaller_${samplename}.vcf |\
perl -ne '@c=split(/\t/,$_); @a=split(":",$c[9]); @b=split(",",$a[1]); if ($b[0]+$b[1]>=20) {print $_}' \
> /Jan-Lab/zhengchen/correct_cov/cov_sen/bulk/${samplename}.hs.vcf

