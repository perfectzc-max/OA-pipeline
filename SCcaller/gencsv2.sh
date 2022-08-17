id=$1

bam_length=$(ls /Jan-Lab/zhengchen/nfscore/$id/results/Preprocessing/*/Recalibrated/P*bam |wc -l)
bam_length=$(($bam_length-1))
bam=$(ls /Jan-Lab/zhengchen/nfscore/$id/results/Preprocessing/*/Recalibrated/P*bam | head -$bam_length )
bam_b=$(ls /Jan-Lab/zhengchen/nfscore/$id/results/Preprocessing/*/Recalibrated/P*bam | tail -1 )
vcf=$(ls /Jan-Lab/zhengchen/nfscore/$id/results/VariantCalling/P*/HaplotypeCaller/filter_*.vcf)


#bam=$(head -5 $1)
#bam_b=$(tail -1 $1)
#vcf=$(cat $2)


#echo $bam_length
#echo $vcf

rm ./$id/samplsheet$id.csv
for line in $bam
do
        sc_id=$(echo $line | awk -F "/" '{print $8}')
        sc_bam=$(echo $line | awk -F ',' '{print $0}')
        bulk_bam=$bam_b
        bulk_vcf=$vcf
        echo $sc_id,$sc_bam,$bulk_bam,$bulk_vcf >>./$id/samplsheet$id.csv
done
