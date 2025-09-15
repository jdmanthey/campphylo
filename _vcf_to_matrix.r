
options(scipen=999)

# input args <- input file, popmap
args <- commandArgs(trailingOnly = TRUE)


####################################
# read in a small vcf (don't use 
# for large vcf files)
####################################
read_vcf <- function(input_file) {
  header <- readLines(input_file)
  header <- header[grep('^#C', header)]
  header <- strsplit(header, "\t")[[1]]
  vcf <- read.table(input_file, header=F)
  colnames(vcf) <- header
  return(vcf)
}




####################################
# convert VCF to data matrix with 
# called base pairs
# heterozygous sites choose one allele
# at random
####################################
convert_vcf_data_matrix <- function(xxx, outname) {
		
	# subset the genotypes from the allele info
	allele_info <- xxx[,c(4,5)]
	genotypes <- xxx[,10:ncol(xxx)]
	# define names of individuals in output fasta
	output_names_fasta <- paste(">", colnames(genotypes), sep="")
	
	# define heterozygous ambiguities
   	het <- rep("N", nrow(allele_info))
   	het[allele_info[,1] == "A" & allele_info[,2] == "C"] <- "M"
   	het[allele_info[,1] == "A" & allele_info[,2] == "G"] <- "R"
 	het[allele_info[,1] == "A" & allele_info[,2] == "T"] <- "W"
 	het[allele_info[,1] == "C" & allele_info[,2] == "A"] <- "M"
 	het[allele_info[,1] == "C" & allele_info[,2] == "G"] <- "S"
  	het[allele_info[,1] == "C" & allele_info[,2] == "T"] <- "Y"
   	het[allele_info[,1] == "G" & allele_info[,2] == "A"] <- "R"
  	het[allele_info[,1] == "G" & allele_info[,2] == "C"] <- "S"
   	het[allele_info[,1] == "G" & allele_info[,2] == "T"] <- "K"
   	het[allele_info[,1] == "T" & allele_info[,2] == "A"] <- "W"
  	het[allele_info[,1] == "T" & allele_info[,2] == "C"] <- "Y"
   	het[allele_info[,1] == "T" & allele_info[,2] == "G"] <- "K"
       	
   	# convert all numbers in genotypes to actual bases and ambiguities		
	for(a in 1:ncol(genotypes)) {
		# keep only genotype
		genotypes[,a] <- substr(genotypes[,a], 1, 3)
		# convert to bases
		genotypes[,a][genotypes[,a] == "0/0"] <- allele_info[genotypes[,a] == "0/0",1]
		genotypes[,a][genotypes[,a] == "1/1"] <- allele_info[genotypes[,a] == "1/1",2]
		genotypes[,a][genotypes[,a] == "./."] <- "?"
		genotypes[,a][genotypes[,a] == "0/1"] <- het[genotypes[,a] == "0/1"]
		# choose random allele for heterozygotes
		genotypes[,a][genotypes[,a] == "R"] <- sample(c("A", "G"), length(genotypes[,a][genotypes[,a] == "R"]), replace=T)
		genotypes[,a][genotypes[,a] == "K"] <- sample(c("T", "G"), length(genotypes[,a][genotypes[,a] == "K"]), replace=T)
		genotypes[,a][genotypes[,a] == "S"] <- sample(c("C", "G"), length(genotypes[,a][genotypes[,a] == "S"]), replace=T)
		genotypes[,a][genotypes[,a] == "Y"] <- sample(c("C", "T"), length(genotypes[,a][genotypes[,a] == "Y"]), replace=T)
		genotypes[,a][genotypes[,a] == "M"] <- sample(c("A", "C"), length(genotypes[,a][genotypes[,a] == "M"]), replace=T)
		genotypes[,a][genotypes[,a] == "W"] <- sample(c("A", "T"), length(genotypes[,a][genotypes[,a] == "W"]), replace=T)
	}
	
	# write output
	write.table(genotypes, file=outname, quote=F, row.names=F, sep="\t")
}



####################################
# make data matrix 
####################################
# read vcf
input_file <- read_vcf(args[1])
# define output  name
output_name <- paste(strsplit(args[1], ".recode.vcf")[[1]][1], ".txt", sep="")
# create data matrix with balled bases from vcf
convert_vcf_data_matrix(input_file, output_name)

