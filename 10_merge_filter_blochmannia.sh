#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=merge
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --partition=nocona
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G

source activate bcftools

# define main working directory
workdir=/lustre/scratch/jmanthey/08_ant_phylo

# run bcftools to merge the vcf files
bcftools merge ${workdir}/01_blochmannia/*filtered.vcf.gz > \
${workdir}/01_blochmannia/total.vcf

# filter based on missing data for phylogenetics
vcftools --vcf ${workdir}/01_blochmannia/total.vcf --keep bloch.txt --max-missing 1.0 \
--max-alleles 2 --max-maf 0.49 --recode --recode-INFO-all \
--out ${workdir}/01_blochmannia/total_filtered1.vcf

vcftools --vcf ${workdir}/01_blochmannia/total.vcf --keep bloch.txt --max-missing 0.95 \
--max-alleles 2 --max-maf 0.49 --recode --recode-INFO-all \
--out ${workdir}/01_blochmannia/total_filtered2.vcf

vcftools --vcf ${workdir}/01_blochmannia/total.vcf --keep bloch.txt --max-missing 0.9 \
--max-alleles 2 --max-maf 0.49 --recode --recode-INFO-all \
--out ${workdir}/01_blochmannia/total_filtered3.vcf

