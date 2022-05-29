#!/bin/bash


### 
### This is a help document.
###
### Usage:
###   run_sccaller.sh <refs> <inputfile> <outdir>
###
### Options:
###   <refs>	GRCh37 or GRCh38 or GRCm38.
###   <inputfile>	The absolute path to samplesheet.
###   <outdir>	Must be an absolute path.
###   -h	Help document.
###
### Path to this script: /Software/pipelines/SCcaller
### Get more information of this pipeline: https://github.com/biosinodx/SCcaller/
###
###
###

help() {
    sed -rn 's/^### ?//;T;p' "$0"
}

if [[ $# == 0 ]] || [[ "$1" == "-h" ]]
	then
		help
		exit
elif [[ "$2" == "" ]]
	then
		refs=$1
		if [[ "$refs" == "GRCh37"  ]] || [[ "$refs" == "GRCh38" ]] || [[ "$refs" == "GRCm38" ]]
			then
				echo -e "\nRefs set to $refs. Inputfile and Outdir not specified. \n"
				exit
		else
			echo -e "\nInvalid Refs. \n"
			exit
		fi
elif [[ "$3" == "" ]]
	then
		refs=$1 && inputfile=$2
		if [[ "$refs" == "GRCh37"  ]] || [[ "$refs" == "GRCh38" ]] || [[ "$refs" == "GRCm38" ]]
			then
				echo -e "\nRefs set to $refs. Inputfile set to $inputfile. \nOutdir not specified. \n"
				exit
		else
			echo -e "\nInvalid Refs. \n"
			exit
		fi
else
	refs=$1 && inputfile=$2 && outdir=$3
	if [[ "$refs" == "GRCh37" ]]
		then
			reference=/Software/Refs/references/Homo_sapiens/GATK/GRCh37/Sequence/WholeGenomeFasta/human_g1k_v37_decoy.fasta
			echo -e "\nRefs set to $refs, Inputfile set to $inputfile. \nOutdir set to $outdir. \n"
	elif [[ "$refs" == "GRCh38" ]]
		then
			reference=/Software/Refs/references/Homo_sapiens/GATK/GRCh38/Sequence/WholeGenomeFasta/Homo_sapiens_assembly38.fasta
			echo -e "\nRefs set to $refs, Inputfile set to $inputfile. \nOutdir set to $outdir. \n"
	elif [[ "$refs" == "GRCm38" ]]
		then
			reference=/Software/Refs/references/Mus_musculus/Ensembl/GRCm38/Sequence/WholeGenomeFasta/genome.fa
			echo -e "\nRefs set to $refs, Inputfile set to $inputfile. \nOutdir set to $outdir. \n"
	else
		echo -e "\nInvalid Refs. \n"
		exit
	fi
fi

export PATH=$PATH:/Software/Packages/samtools-1.10/
prefix=/Software/pipelines/SCcaller/


for line in $(cat $inputfile | grep -v "#")
do
	sc_id=$(echo $line | awk -F ',' '{print $1}')
	sc_bam=$(echo $line | awk -F ',' '{print $2}')
	bulk_bam=$(echo $line | awk -F ',' '{print $3}')
	bulk_vcf=$(echo $line | awk -F ',' '{print $4}')
	export sc_id
	export sc_bam
	export bulk_bam
	export bulk_vcf
	export reference
	export outdir
	sbatch_file=$(echo $prefix'sccaller.sbatch')
	sbatch $sbatch_file
done
