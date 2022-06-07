#list vcf file of bulk
ls /Jan-Lab/zhengchen/nfscore/P*/results/VariantCalling/*/HaplotypeCaller/HaplotypeCaller_*B.vcf |awk -F "/" '{print $8 }' >bulk.txt

#filter out rows without IDS, filter out non-heterozygous sites, filter out those without passes
#filter out depth < 20x
for i in $(cat bulk.txt);do echo "nohup sh 1_vcf_collect.sh $i &" ;done |bash
