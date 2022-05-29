#!/bin/bash
#SBATCH --partition=cpu
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 10
#SBATCH --job-name SCcaller
#SBATCH --output SCcaller-%J.out
#SBATCH --error SCcaller-%J.err

/Software/Packages/Python2.7_for_sccaller/bin/python /Software/Packages/SCcaller-master/sccaller_v2.0.0.py \
--bam $sc_bam \
--bulk $bulk_bam \
--fasta $reference \
--output $outdir/$sc_id.output.vcf \
--snp_type hsnp \
--snp_in $bulk_vcf  \
--cpu_num 10 \
--engine samtools
