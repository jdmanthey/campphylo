#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=zip
#SBATCH --partition nocona
#SBATCH --nodes=1 --ntasks=2
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-8

# gzip any files that are not already

basename_array=$( head -n${SLURM_ARRAY_TASK_ID} zip_files.txt | tail -n1 )

gzip ${basename_array}
