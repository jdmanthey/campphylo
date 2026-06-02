#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=minys
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --partition=nocona
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=6G
#SBATCH --array=1-60

source activate minys

# define main working directory
workdir=/lustre/scratch/jmanthey/09_antphylo

basename_array=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/basenames.txt | tail -n1 )

MinYS.py -1 ${workdir}/00_fastq/${basename_array}_R1.fastq.gz \
-2 ${workdir}/00_fastq/${basename_array}_R2.fastq.gz \
-ref /home/jmanthey/blochmannia/combined.fasta \
-out ${workdir}/19_minys/${basename_array} -nb-cores 12
