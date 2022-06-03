path=$1
cell=$2

echo ${path}\/${cell}\.vcf  ${cell}\.snv.vcf
#snv
grep '0/1' ${path}\/${cell}\.vcf | grep 'True' | awk '$7=="." && length($5)==1' | awk -F "[:,]" '$8+$9>=20' > ${cell}\.snv.vcf

#indel
grep '0/1' ${path}\/${cell}\.vcf | grep 'True' | awk '$7=="." && length($5)>1' | awk -F "[:,]" '$8+$9>=20' > ${cell}\.indel.vcf

#header
grep '#' ${path}\/${cell}\.vcf > ${cell}\.header.vcf

#add header
cat ${cell}\.header.vcf ${cell}\.snv.vcf > ${cell}\.snv.run.vcf
cat ${cell}\.header.vcf ${cell}\.indel.vcf > ${cell}\.indel.run.vcf

#dbsnp annotate
java -jar /Software/Packages/snpEff/SnpSift.jar annotate /Jan-Lab/zhengchen/snpEff/ref/144-All.vcf.gz ${cell}\.snv.run.vcf >${cell}\.snv.dbsnp.vcf

#filter dbsnp
awk '$3== "." && length($1) <3' ${cell}\.snv.dbsnp.vcf >${cell}\.snv.ann.vcf

#snpeff
export NXF_SINGULARITY_CACHEDIR=/Software/nf_core/singularity_imgs/sarek_v2.7/
/Software/nf_core/NEXTFLOW/nextflow run /Software/nf_core/nf-core-sarek-2.7/workflow/  --input ${cell}\.snv.ann.vcf --tools SnpEff  --step annotate  --outdir SnpEff_result  --genome GRCh37  --igenomes_base /Software/Refs/references  --species homo_sapiens  -profile singularity  -c /Software/nf_core/slurm_config/slurm_submit.config  -bg

echo ${cell} "done"
