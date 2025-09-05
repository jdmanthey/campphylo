#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=genotype
#SBATCH --partition nocona
#SBATCH --nodes=1 --ntasks=4
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --array=1-71

source activate bcftools

threads=4

# define main working directory
workdir=/lustre/scratch/jmanthey/08_ant_phylo

# base name of fastq files, intermediate files, and output files
basename_array=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/basenames.txt | tail -n1 )

# define the reference genome
refgenome=/home/jmanthey/blochmannia/16_pennunk.fasta

# repair if truncated at all or any read pairs removed
/lustre/work/jmanthey/bbmap/repair.sh \
in=${workdir}/01_blochmannia/${basename_array}_combined.fastq.gz \
out1=${workdir}/01_blochmannia/${basename_array}_R1.fastq.gz \
out2=${workdir}/01_blochmannia/${basename_array}_R2.fastq.gz \
outs=${workdir}/01_blochmannia/${basename_array}_S.fastq.gz

# remove unneeded file
rm ${workdir}/01_blochmannia/${basename_array}_S.fastq.gz

# run bwa mem
bwa-mem2 mem -t ${threads} ${refgenome} \
${workdir}/01_blochmannia/${basename_array}_R1.fastq.gz \
${workdir}/01_blochmannia/${basename_array}_R2.fastq.gz > \
${workdir}/01_blochmannia/${basename_array}.sam

# convert sam to bam
samtools view -b -S -@ ${threads} \
-o ${workdir}/01_blochmannia/${basename_array}.bam \
${workdir}/01_blochmannia/${basename_array}.sam

# remove sam
rm ${workdir}/01_blochmannia/${basename_array}.sam

# clean up the bam file
java -jar /home/jmanthey/picard.jar CleanSam \
I=${workdir}/01_blochmannia/${basename_array}.bam \
O=${workdir}/01_blochmannia/${basename_array}_cleaned.bam

# remove the raw bam
rm ${workdir}/01_blochmannia/${basename_array}.bam

# sort the cleaned bam file
java -jar /home/jmanthey/picard.jar SortSam \
I=${workdir}/01_blochmannia/${basename_array}_cleaned.bam \
O=${workdir}/01_blochmannia/${basename_array}_cleaned_sorted.bam SORT_ORDER=coordinate

# remove the cleaned bam file
rm ${workdir}/01_blochmannia/${basename_array}_cleaned.bam

# add read groups to sorted and cleaned bam file
java -jar /home/jmanthey/picard.jar AddOrReplaceReadGroups \
I=${workdir}/01_blochmannia/${basename_array}_cleaned_sorted.bam \
O=${workdir}/01_blochmannia/${basename_array}_cleaned_sorted_rg.bam \
RGLB=1 RGPL=illumina RGPU=unit1 RGSM=${basename_array}

# remove cleaned and sorted bam file
rm ${workdir}/01_blochmannia/${basename_array}_cleaned_sorted.bam

# remove duplicates to sorted, cleaned, and read grouped bam file (creates final bam file)
java -jar /home/jmanthey/picard.jar MarkDuplicates REMOVE_DUPLICATES=true \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=100 \
M=${workdir}/01_blochmannia/${basename_array}_markdups_metric_file.txt \
I=${workdir}/01_blochmannia/${basename_array}_cleaned_sorted_rg.bam \
O=${workdir}/01_blochmannia/${basename_array}_final.bam

# remove sorted, cleaned, and read grouped bam file
rm ${workdir}/01_blochmannia/${basename_array}_cleaned_sorted_rg.bam

# index the final bam file
samtools index ${workdir}/01_blochmannia/${basename_array}_final.bam

# run bcftools to genotype
bcftools mpileup --skip-indels -C 0 -d 200 --min-MQ 10 --threads ${threads} \
-f ${refgenome} ${workdir}/01_blochmannia/${basename_array}_final.bam | \
bcftools call -m --threads ${threads} --ploidy 1 -o ${workdir}/01_blochmannia/${basename_array}.vcf

# bgzip
bgzip ${workdir}/01_blochmannia/${basename_array}.vcf

#tabix
tabix ${workdir}/01_blochmannia/${basename_array}.vcf.gz

# filter individual vcf files
bcftools view -i 'MIN(DP)>50' ${workdir}/01_blochmannia/${basename_array}.vcf.gz > \
${workdir}/01_blochmannia/${basename_array}_filtered.vcf

# bgzip
bgzip ${workdir}/01_blochmannia/${basename_array}_filtered.vcf

#tabix
tabix ${workdir}/01_blochmannia/${basename_array}_filtered.vcf.gz

# alignment stats
echo ${basename_array} > ${basename_array}.stats

# samtools depth sum of aligned sites
echo "samtools depth sum of aligned sites" >> ${basename_array}.stats
samtools depth  ${workdir}/01_blochmannia/${basename_array}_final.bam  |  \
awk '{sum+=$3} END { print "Sum = ",sum}' >> ${basename_array}.stats

# number of genotyped sites passing minimum depth filter
echo "sites genotyped" >> ${basename_array}.stats
gzip -cd ${workdir}/01_blochmannia/${basename_array}_filtered.vcf.gz | grep -v "^#" | \
wc -l >> ${basename_array}.stats



