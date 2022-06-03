#nf-core
#including fastQC, trimgalore, mapping and sort
#use hapllotype caller call germline mutation, also preformed BQSR, bamQC

#run nf-core
#creat samplesheet like samplesheet.tsv 
run_nfcore_haplotypecaller_vep.sh GRCh37 /Jan-Lab/zhengchen/nfscore/P13N/samplesheetp13N.tsv /Jan-Lab/zhengchen/nfscore/P13N

#prepare SCcaller
#unzip vcf file
gunzip /Jan-Lab/zhengchen/nfscore/P13N/results/VariantCalling/P*/HaplotypeCaller/*.gz

#list bam and vcf file
ls /Jan-Lab/zhengchen/nfscore/P*/results/VariantCalling/P*/HaplotypeCaller/HaplotypeCaller_P7*L*B.vcf > vcf_p7L.txt
ls /Jan-Lab/zhengchen/nfscore/P*/results/Preprocessing/*/Recalibrated/P7*L*bam > samplelist_p7L.txt

#creat a input file like input.csv
#run sccaller
run_sccaller.sh GRCh37 input.csv /Jan-Lab/zhengchen/sccaller

#filter
#grep '0/1' cell.vcf | grep 'True' | awk '$7=="." && length($5)==1' | awk -F "[:,]" '$8+$9>=20' > cell.somatic.snv.vcf
#grep '0/1' cell.vcf | grep 'True' | awk '$7=="." && length($5)>1' | awk -F "[:,]" '$8+$9>=30' > cell.somatic.indel.vcf

#vcf list 
ls /Jan-Lab/zhengchen/sccaller/P*/*B.vcf >vcf.txt
#indel and snv
sed -e s/"\/P"/:P/g vcf.txt | awk -F "[:.]" '{print "sh code.sh "  $1"/"$2 " "$3}' |head -1 |bash
