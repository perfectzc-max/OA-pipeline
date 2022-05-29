#nf-core
#including fastQC, trimgalore, mapping and sort
#use hapllotype caller call germline mutation, also preformed BQSR, bamQC

#run nf-core
run_nfcore_haplotypecaller_vep.sh GRCh37 /Jan-Lab/zhengchen/nfscore/P13N/samplesheetp13N.tsv /Jan-Lab/zhengchen/new/P13N

