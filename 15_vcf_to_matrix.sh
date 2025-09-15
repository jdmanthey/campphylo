#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=convert
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --partition=nocona
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-31

source activate bcftools

# define main working directory
workdir=/lustre/scratch/jmanthey/08_ant_phylo

# define variables
region_array=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/scaffolds.txt | tail -n1 )

# convert vcf to matrix for each scaffold
Rscript _vcf_to_matrix.r ${region_array}.recode.vcf



