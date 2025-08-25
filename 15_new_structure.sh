# start interactive session
interactive -p quanah -c 4 -m 8G

source activate bcftools

# move to directory
workdir=/lustre/scratch/jmanthey/08_ant_phylo
cd ${workdir}/10_eems

# combine all chromosome vcfs into one vcf for the two different datasets
grep "#" scaffold0025.recode.vcf > structure.vcf
for i in $( ls scaffold*recode.vcf ); do grep -v "#" $i >> structure.vcf; done

# thin by 5 kbp
vcftools --vcf structure.vcf --thin 5000 --recode --recode-INFO-all \
--out structure_5kbp_thin


# make chromosome map for the vcf
grep -v "#" structure_5kbp_thin.recode.vcf | cut -f 1 | uniq | awk '{print $0"\t"$0}' > chrom_map.txt

# run vcftools for the vcf
vcftools --vcf structure_5kbp_thin.recode.vcf  --plink --chrom-map chrom_map.txt --out structure 

# convert  with plink
plink --file structure --recode12 --allow-extra-chr --out structure_plink

# run pca 
plink --file structure_plink --pca --allow-extra-chr --out structure_plink_pca

# run admixture on the dataset
for K in 1 2 3 4 5; do admixture --cv structure_plink.ped $K; done
