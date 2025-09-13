#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=bootsnaq
#SBATCH --partition nocona
#SBATCH --nodes=1 --ntasks=1
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --array=1-100

julia _runSNaQ.jl $SLURM_ARRAY_TASK_ID