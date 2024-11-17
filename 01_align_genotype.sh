#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=genotype
#SBATCH --partition nocona
#SBATCH --nodes=1 --ntasks=20
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --array=1-60

source activate bcftools

threads=18

# define main working directory
workdir=/lustre/scratch/jmanthey/06_ant_phylogenomics

# base name of fastq files, intermediate files, and output files
basename_array=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/basenames.txt | tail -n1 )

# define the reference genome
refgenome=/home/jmanthey/denovo_genomes/camp_sp_genome_filtered.fasta

# define the location of the reference mitogenomes
mito=/home/jmanthey/denovo_genomes/formicinae_mitogenomes.fasta

# define the location of the reference blochmannia genomes
bloch=/home/jmanthey/blochmannia/combined.fasta

# run bbduk
/lustre/work/jmanthey/bbmap/bbduk.sh \
in1=${workdir}/00_fastq/${basename_array}_R1.fastq.gz \
in2=${workdir}/00_fastq/${basename_array}_R2.fastq.gz \
out1=${workdir}/01_cleaned/${basename_array}_R1.fastq.gz \
out2=${workdir}/01_cleaned/${basename_array}_R2.fastq.gz \
minlen=50 ftl=10 qtrim=rl trimq=10 ktrim=r k=25 mink=7 \
ref=/lustre/work/jmanthey/bbmap/resources/adapters.fa hdist=1 tbo tpe

# run bbsplit
/lustre/work/jmanthey/bbmap/bbsplit.sh \
in1=${workdir}/01_cleaned/${basename_array}_R1.fastq.gz \
in2=${workdir}/01_cleaned/${basename_array}_R2.fastq.gz \
ref=${mito} basename=${workdir}/01_mtDNA/${basename_array}_%.fastq.gz \
outu1=${workdir}/01_mtDNA/${basename_array}_R1.fastq.gz \
outu2=${workdir}/01_mtDNA/${basename_array}_R2.fastq.gz

# remove unnecessary bbsplit output files
rm ${workdir}/01_mtDNA/${basename_array}_R1.fastq.gz
rm ${workdir}/01_mtDNA/${basename_array}_R2.fastq.gz

# run bbsplit
/lustre/work/jmanthey/bbmap/bbsplit.sh \
in1=${workdir}/01_cleaned/${basename_array}_R1.fastq.gz \
in2=${workdir}/01_cleaned/${basename_array}_R2.fastq.gz \
ref=${bloch} basename=${workdir}/01_blochmannia/${basename_array}_%.fastq.gz \
outu1=${workdir}/01_blochmannia/${basename_array}_R1.fastq.gz \
outu2=${workdir}/01_blochmannia/${basename_array}_R2.fastq.gz

# remove unnecessary bbsplit output files
rm ${workdir}/01_blochmannia/${basename_array}_R1.fastq.gz
rm ${workdir}/01_blochmannia/${basename_array}_R2.fastq.gz

# run bwa mem
bwa-mem2 mem -t ${threads} ${refgenome} \
${workdir}/01_cleaned/${basename_array}_R1.fastq.gz \
${workdir}/01_cleaned/${basename_array}_R2.fastq.gz > \
${workdir}/01_bam_files/${basename_array}.sam

# convert sam to bam
samtools view -b -S -@ ${threads} \
-o ${workdir}/01_bam_files/${basename_array}.bam \
${workdir}/01_bam_files/${basename_array}.sam

# remove sam
rm ${workdir}/01_bam_files/${basename_array}.sam

# clean up the bam file
java -jar /home/jmanthey/picard.jar CleanSam \
I=${workdir}/01_bam_files/${basename_array}.bam \
O=${workdir}/01_bam_files/${basename_array}_cleaned.bam

# remove the raw bam
rm ${workdir}/01_bam_files/${basename_array}.bam

# sort the cleaned bam file
java -jar /home/jmanthey/picard.jar SortSam \
I=${workdir}/01_bam_files/${basename_array}_cleaned.bam \
O=${workdir}/01_bam_files/${basename_array}_cleaned_sorted.bam SORT_ORDER=coordinate

# remove the cleaned bam file
rm ${workdir}/01_bam_files/${basename_array}_cleaned.bam

# add read groups to sorted and cleaned bam file
java -jar /home/jmanthey/picard.jar AddOrReplaceReadGroups \
I=${workdir}/01_bam_files/${basename_array}_cleaned_sorted.bam \
O=${workdir}/01_bam_files/${basename_array}_cleaned_sorted_rg.bam \
RGLB=1 RGPL=illumina RGPU=unit1 RGSM=${basename_array}

# remove cleaned and sorted bam file
rm ${workdir}/01_bam_files/${basename_array}_cleaned_sorted.bam

# remove duplicates to sorted, cleaned, and read grouped bam file (creates final bam file)
java -jar /home/jmanthey/picard.jar MarkDuplicates REMOVE_DUPLICATES=true \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=100 \
M=${workdir}/01_bam_files/${basename_array}_markdups_metric_file.txt \
I=${workdir}/01_bam_files/${basename_array}_cleaned_sorted_rg.bam \
O=${workdir}/01_bam_files/${basename_array}_final.bam

# remove sorted, cleaned, and read grouped bam file
rm ${workdir}/01_bam_files/${basename_array}_cleaned_sorted_rg.bam

# index the final bam file
samtools index ${workdir}/01_bam_files/${basename_array}_final.bam

# run bcftools to genotype
bcftools mpileup --skip-indels -C 0 -d 200 --min-MQ 10 --threads ${threads} \
-f ${refgenome} ${workdir}/01_bam_files/${basename_array}_final.bam | \
bcftools call -m --threads ${threads} -o ${workdir}/02_vcf/${basename_array}.vcf

# bgzip
bgzip ${workdir}/02_vcf/${basename_array}.vcf

#tabix
tabix ${workdir}/02_vcf/${basename_array}.vcf.gz

# filter individual vcf files
bcftools view -i 'MIN(DP)>5' ${workdir}/02_vcf/${basename_array}.vcf.gz > \
${workdir}/03_vcf/${basename_array}.vcf

# bgzip
bgzip ${workdir}/03_vcf/${basename_array}.vcf

#tabix
tabix ${workdir}/03_vcf/${basename_array}.vcf.gz

# alignment stats
echo ${basename_array} > ${basename_array}.stats

# samtools depth sum of aligned sites
echo "samtools depth sum of aligned sites" >> ${basename_array}.stats
samtools depth  ${workdir}/01_bam_files/${basename_array}_final.bam  |  awk '{sum+=$3} END { print "Sum = ",sum}' >> ${basename_array}.stats

# proportion dupes
echo "proportion duplicates" >> ${basename_array}.stats
head -n8 ${workdir}/01_bam_files/${basename_array}_markdups_metric_file.txt | tail -n1 | cut -f9 >> ${basename_array}.stats

# number of genotyped sites passing minimum depth filter
echo "sites genotyped" >> ${basename_array}.stats
gzip -cd ${workdir}/03_vcf/${basename_array}.vcf.gz | grep -v "^#" | wc -l >> ${basename_array}.stats

# contam check
# extract all heterozygous sites for this individual
vcftools --gzvcf ${workdir}/03_vcf/${basename_array}.vcf.gz --min-alleles 2 --max-alleles 2 \
--maf 0.5 --recode --recode-INFO-all --out ${workdir}/03_contam/${basename_array}

# extract the depth info for all the sites retained
bcftools query -f '%DP4\n' ${workdir}/03_contam/${basename_array}.recode.vcf > ${workdir}/03_contam/${basename_array}.dp

# make a histogram of MAF sequencing depth proportion
Rscript contam_check.r ${workdir}/03_contam/${basename_array}.dp ${basename_array}



