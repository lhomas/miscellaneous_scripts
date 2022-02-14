# miscellaneous_scripts
A collection of random scripts for a variety of purposes.
These have been put together on the fly and are likely bad scripts, please don't judge me too harshly.

# count_liftover_fail.awk
- Script for counting reasons why variants failed liftover with CrossMap. 
- USAGE: awk -f count_liftover_fail.awk /path/to/crossMap_output.vcf.unmap

# splice_AI_filt.sh
- Script for filtering VCF files output from SpliceAI and returning inforamtion about variants that have score above specified threshold.
- bash splice_AI_filt.sh /path/to/spliceAI_output.vcf.gz minimum_score_threshold > splice_vars_output.txt
