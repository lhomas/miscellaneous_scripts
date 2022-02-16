#!/bin/bash

# REQUIRES: BCFtools
#USAGE: linkage_subset_vcf.sh /path/to/file_containing_variants.vcf.gz comma,separated,sample,list output_prefix chr:start-end


# Make sure vcf file is being provided
if ! [[ "${1}" ==  *.vcf.gz || "${1}" ==  *.vcf.gz ]] ; then
		echo "## ERROR ## Need to provide .vcf of .vcf.gz file"
		exit 1
fi

# Make sure sample list isn't empty
if [ -z "${2}" ]; then
	echo "## ERRORR ## Make sure you provide a sample list. Even if vcf only contains the samples you are interested in please provide list any way as not to mess up positional arguments"
	exit 1
fi

# Make sure filie prefix is given
if [ -z "${3}" ]; then 
	echo "## ERROR ## You need to tell me how to name the output files"
	exit 1	
fi

# Make sure region of interest is given and in the right format
if ! [[ ${4} =~ ^[a-zA-Z0-9]+:[0-9]+-[0-9]+$ ]]; then
	echo "## ERROR ## It doesn't look like your region of interest is formatted properly (if there is one at all), please double check to make sure it is correct"
	exit 1
fi

# Split region into constituting parts
chr=$(echo ${4} | awk 'BEGIN { FS = ":" } ; { print $1 }')
start=$(echo ${4} | awk -F [-:] '{ print $2}')
end=$(echo ${4} | awk 'BEGIN { FS = "-" } ; {print $2}')
	
# Subset VCF to just samples of interest
bcftools view -O z -o ${3}_temp.vcf.gz -s ${2} ${1}
tabix ${3}_temp.vcf.gz

# Retain only variants present in either of the two samples (remove instaces where all samples are homozygous for reference allele)
bcftools view -i 'GT[*]="alt"' -O z -o ${3}.vcf.gz ${3}_temp.vcf.gz
tabix ${3}.vcf.gz

# Subset to linkage interval 
bcftools view -O z -o ${3}_LI_${chr}_${start}_${end}.vcf.gz ${1} ${4}
tabix ${3}_LI_${chr}_${start}_${end}.vcf.gz

# Cleanup 
rm ${3}_temp.vcf.gz*
