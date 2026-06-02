#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=pgap
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --partition=nocona
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --array=1-46

name_array=$( head -n${SLURM_ARRAY_TASK_ID} pgap_list.txt | tail -n1 )

basename_array=output_${name_array%.fasta}

workdir=/lustre/scratch/jmanthey/08_ant_phylo/25_pgap

/home/jmanthey/pgap.py --docker singularity \
-r -o ${workdir}/${basename_array} \
-g ${workdir}/${name_array} \
-s 'Candidatus Blochmanniella'
