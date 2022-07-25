# miscellaneous_scripts
A collection of random scripts for a variety of purposes.
These have been put together on the fly and are likely bad scripts, please don't judge me too harshly.

# count_liftover_fail.awk
- Script for counting reasons why variants failed liftover with CrossMap. 
- USAGE: awk -f count_liftover_fail.awk /path/to/crossMap_output.vcf.unmap

# splice_AI_filt.sh
- Script for filtering VCF files output from SpliceAI and returning inforamtion about variants that have score above specified threshold.
- bash splice_AI_filt.sh /path/to/spliceAI_output.vcf.gz minimum_score_threshold > splice_vars_output.txt

# linkage_subset_vcf.sh
- Scfipt to select individuals from multisample vcf and filter down to only variants withing a specified interval
- USAGE: bash linkage_subset_vcf.sh /path/to/file_containing_variants.vcf.gz comma,separated,sample,list output_prefix chr:start-end

# whole_genome_linkage_plots.R
- Script containing functions to generate whole genome linkage plots with R using the output "-parametric.tbl" files produced by Merlin.
- This script cotains a function to generate these plots for a single interation of linkage analysis (plot_genome_linkage) and one to take in multiple iterations of a linkage analysis, sum together the LOD scores, and plot summed totals (plot_combined_genome_linkage).
