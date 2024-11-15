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
mkdir 19_minys
mkdir 20_align_genotype_script
mkdir 21_merge_script
mkdir 22_filter_script
mkdir 23_minys_script

# copy the contam_check.r script to the 20_align_genotype_script directory
