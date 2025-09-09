#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=filter
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=nocona
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-31

source activate bcftools

# define main working directory
workdir=/lustre/scratch/jmanthey/08_ant_phylo

# define variables
region_array=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/scaffolds.txt | tail -n1 )

# filter based on missing data for each of the subsets of data
# for stats and phylogenies
vcftools --vcf ${workdir}/04_vcf/${region_array}.vcf --keep phylo.txt --max-missing 0.9 \
--max-alleles 2 --max-maf 0.49 --recode --recode-INFO-all \
--out ${workdir}/05_filtered_vcf/${region_array}

# for gene flow
vcftools --vcf ${workdir}/04_vcf/${region_array}.vcf --keep phylo.txt --max-missing 0.9 \
--min-alleles 2 --max-alleles 2 --mac 2 --max-maf 0.49 --recode --recode-INFO-all \
--out ${workdir}/08_gene_flow/${region_array}

# for MrBayes -> SNAQ
vcftools --vcf ${workdir}/04_vcf/${region_array}.vcf --keep phylo_subset.txt --max-missing 0.93 \
--max-alleles 2 --max-maf 0.49 --recode --recode-INFO-all \
--out ${workdir}/11_mrbayes/${region_array}


# for new species EEMS + ADMIXTURE + PCA
vcftools --vcf ${workdir}/04_vcf/${region_array}.vcf --keep new.txt --max-missing 1.0 \
--min-alleles 2 --max-alleles 2 --max-maf 0.49 --mac 2 --recode --recode-INFO-all \
--out ${workdir}/10_eems/${region_array}

# filter for divergence measurement in genes
# bedtools to extract cds regions
# get header
grep "^#" ${workdir}/05_filtered_vcf/${region_array}.recode.vcf > \
${workdir}/06_divergence/${region_array}.vcf
# intersect
bedtools intersect -a ${workdir}/05_filtered_vcf/${region_array}.recode.vcf \
-b /home/jmanthey/denovo_annotations/camp_round2_cds.gff >> \
${workdir}/06_divergence/${region_array}.vcf
# further filter for missingness and ingroup only
vcftools --vcf ${workdir}/06_divergence/${region_array}.vcf --keep ingroup.txt --max-missing 1.0 \
--recode --recode-INFO-all --out ${workdir}/06_divergence/${region_array}_filtered


# zip and index the stats files
bgzip ${workdir}/05_filtered_vcf/${region_array}.recode.vcf

tabix ${workdir}/05_filtered_vcf/${region_array}.recode.vcf.gz




