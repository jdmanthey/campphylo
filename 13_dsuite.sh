#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=dsuite
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --partition=nocona
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=4G

# combine VCF files

grep "#" scaffold0031.recode.vcf > camponotus.vcf

for i in $( ls scaffold*.recode.vcf ); do grep -v "^#" $i >> camponotus.vcf; done

# run Dtrios
Dsuite Dtrios -t camponotus_dsuite.tre camponotus.vcf camp_dsuite.txt

# run Fbranch
Dsuite Fbranch camponotus_dsuite.tre camp_dsuite_tree.txt > fbranch_output.txt

# plot Fbranch
dtools.py fbranch_output.txt camponotus_dsuite.tre 

