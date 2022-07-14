bam=$(head -5 $1)
bam_b=$(tail -1 $1)
vcf=$(cat $2)


#echo $bam
#echo $vcf

for line in $bam
do
        sc_id=$(echo $line | awk -F "/" '{print $8}')
        sc_bam=$(echo $line | awk -F ',' '{print $0}')
        bulk_bam=$bam_b
        bulk_vcf=$vcf
        echo $sc_id,$sc_bam,$bulk_bam,$bulk_vcf
done


