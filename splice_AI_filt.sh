#!/bin/bash

# USAGE: bash splice_AI_filt.sh /path/to/spliceAI_output.vcf.gz <minimum_splice_value_threshold>
# minimum_splice_value_threshold: set this to the lowest spliceAI value you are interested in (A good default is 0.2)

# Check that positional arguments are being used correctly

if ! [[ "${1}" ==  *.vcf.gz || "${1}" ==  *.vcf.gz ]] ; then
		echo "## ERROR ## Need to provide .vcf of .vcf.gz file"
		exit 1
fi

re='^[0-9]+([.][0-9]+)?$'
if ! [[ ""${2}"" =~ $re && $( echo "${2}>1" | bc ) == 1 ]] ; then
	echo "## ERROR ## Nedd to povide a non-negative decimal equal to or below 1.0"
	exit 1
fi


# Filter to vars with alt alleles that were analysed by spliceAI
bcftools view -H ${1} -i 'GT[*]="alt"' | grep SpliceAI > splice_vars.txt

# Isolate chr, positions and SpliceAI fields
cat splice_vars.txt | tr ";" "\t" | awk '{print $1"\t"$2"\t"$(NF-3)}' > pos_splice.txt

# For positions with multiple variants, split them onto separate lines
awk '{if($3 ~/,/)} {gsub(",", "\n"$1"\t"$2"\tSpliceAI=")}; {print $0}' pos_splice.txt > pos_splice_corrected.txt

# Sort for scores above 0.2
cat pos_splice_corrected.txt | tr "|" "\t" | awk -v n=${2} '{if ($5 >= n || $6 >= n || $7 >= n || $8 >= n) {print $0}}'


rm splice_vars.txt
rm pos_splice.txt
rm pos_splice_corrected.txt