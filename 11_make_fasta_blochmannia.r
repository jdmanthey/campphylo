options(scipen=999)


create_fasta_from_vcf <- function(xxx, outname, num_sites_needed) {
	# keep going only if enough sites
	if(num_sites_needed <= nrow(xxx)) {
		
		# subset the genotypes from the allele info
		allele_info <- xxx[,c(4,5)]
		genotypes <- xxx[,10:ncol(xxx)]
		# define names of individuals in output fasta
		output_names_fasta <- paste(">", colnames(genotypes), sep="")
		

       	# convert all numbers in genotypes to actual bases and ambiguities		
		for(a in 1:ncol(genotypes)) {
			# keep only genotype
			genotypes[,a] <- substr(genotypes[,a], 1, 1)
			# convert to bases
			genotypes[,a][genotypes[,a] == "0"] <- allele_info[genotypes[,a] == "0",1]
			genotypes[,a][genotypes[,a] == "1"] <- allele_info[genotypes[,a] == "1",2]
			genotypes[,a][genotypes[,a] == "."] <- "?"
		}
    
		# write output
		for(a in 1:ncol(genotypes)) {
			if(a == 1) {
				write(output_names_fasta[a], file=outname, ncolumns=1)
				write(paste(genotypes[,a], collapse=""), file=outname, ncolumns=1, append=T)
			} else {
				write(output_names_fasta[a], file=outname, ncolumns=1, append=T)
				write(paste(genotypes[,a], collapse=""), file=outname, ncolumns=1, append=T)
			}
		}
	}
}


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



# make fasta files
x <- read_vcf("total_filtered1.vcf.recode.vcf")

create_fasta_from_vcf(x, "blochmannia_100percent.fasta", 10000)

x <- read_vcf("total_filtered2.vcf.recode.vcf")

create_fasta_from_vcf(x, "blochmannia_95percent.fasta", 10000)

x <- read_vcf("total_filtered3.vcf.recode.vcf")

create_fasta_from_vcf(x, "blochmannia_90percent.fasta", 10000)



