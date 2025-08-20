# move to working directory
# 00_fastq directory already there with all the raw data files in *fastq.gz format

# reference genome already indexed from previous study

# make directories for organization during analyses
mkdir 01_cleaned
mkdir 01_mtDNA
mkdir 01_blochmannia
mkdir 01_bam_files
mkdir 02_vcf
mkdir 03_vcf
mkdir 03_contam
mkdir 04_vcf
mkdir 05_filtered_vcf
mkdir 05_filtered_vcf/windows
mkdir 06_divergence
mkdir 07_mcmctree
mkdir 08_gene_flow
mkdir 09_ils
mkdir 10_eems

mkdir 20_bloch_vcf
mkdir 21_bloch_vcf
mkdir 22_bloch_vcf_filtered
mkdir 23_bloch_phylo
mkdir 24_minys
mkdir 25_gapseq

mkdir 30_align_genotype_script
mkdir 31_merge_script
mkdir 32_filter_script

# copy the contam_check.r script to the 20_align_genotype_script directory
