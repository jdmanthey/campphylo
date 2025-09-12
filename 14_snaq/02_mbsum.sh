#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=mbsum
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=nocona
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G

source activate bcftools

# mbsum on final 200 of 1001 trees
for i in $( ls *nex.t ); do mbsum -n 801 $i; done

