#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=genotype
#SBATCH --partition nocona
#SBATCH --nodes=1 --ntasks=4
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-60

source activate bcftools

# define main working directory
workdir=/lustre/scratch/jmanthey/09_antphylo

basename_array=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/basenames.txt | tail -n1 )

# define the reference genome
refgenome=/home/jmanthey/denovo_genomes/camp_sp_genome_filtered.fasta

# run bcftools to genotype
bcftools mpileup --skip-indels -C 0 -d 200 --min-MQ 10 --threads 4 -f ${refgenome} ${workdir}/01_bam_files/${basename_array}_final.bam | bcftools call -m --threads 4 -o ${workdir}/02_vcf/${basename_array}.vcf

# bgzip
bgzip ${workdir}/02_vcf/${basename_array}.vcf

#tabix
tabix ${workdir}/02_vcf/${basename_array}.vcf.gz

# filter individual vcf files
bcftools view -i 'MIN(DP)>5' ${workdir}/02_vcf/${basename_array}.vcf.gz > ${workdir}/03_vcf/${basename_array}.vcf

# bgzip
bgzip ${workdir}/03_vcf/${basename_array}.vcf

#tabix
tabix ${workdir}/03_vcf/${basename_array}.vcf.gz

# contam check
# extract all heterozygous sites for this individual
vcftools --gzvcf ${workdir}/03_vcf/${basename_array}.vcf.gz --min-alleles 2 --max-alleles 2 \
--maf 0.5 --recode --recode-INFO-all --out ${workdir}/03_contam/${basename_array}

# extract the depth info for all the sites retained
bcftools query -f '%DP4\n' ${workdir}/03_contam/${basename_array}.recode.vcf > ${workdir}/03_contam/${basename_array}.dp

# make a histogram of MAF sequencing depth proportion
Rscript contam_check.r ${workdir}/03_contam/${basename_array}.dp ${basename_array}




