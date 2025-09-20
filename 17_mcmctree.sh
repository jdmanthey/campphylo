# perform the above steps, then run the mcmctree script at the bottom for two
# runs in the mcmc1 and mcmc2 directories

mcmctree camponotus_mcmctree_control_approx.txt

mkdir mcmc1
mkdir mcmc2

cd mcmc1

cp ../out.BV in.BV

cp ../camponotus.phy .

cp ../camponotus_mcmctree.tre .

cp ../camponotus_mcmctree_control_mcmc.txt .

cd ../mcmc2

cp ../out.BV in.BV

cp ../camponotus.phy .

cp ../camponotus_mcmctree.tre .

cp ../camponotus_mcmctree_control_mcmc.txt .



#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=mcmctree
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --partition=nocona
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=4G

mcmctree camponotus_mcmctree_control_mcmc.txt

