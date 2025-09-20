options(scipen=999)

x_files <- list.files(pattern="scaffold*")

# process all files to counts
for(a in 1:length(x_files)) {
	print(a)
	# read in file
	x <- read.table(x_files[a], sep="\t", header=T)
	
	# pull out the patterns in the alignment 
	x_patterns <- apply(x, 1, function(x) paste0(x, collapse=''))
	# and the unique patterns
	x_patterns_unique <- unique(x_patterns)

	# loop to count all unique patterns
	x_patterns_loop <- x_patterns
	pattern_counts <- rep(0, length(x_patterns_unique))
	for(b in 1:length(x_patterns_unique)) {
		pattern_counts[b] <- length(x_patterns_loop[x_patterns_loop == x_patterns_unique[b]])
		x_patterns_loop <- x_patterns_loop[x_patterns_loop != x_patterns_unique[b]]
	}

	# combine patterns and counts
	output <- data.frame(patterns=as.character(x_patterns_unique), counts=as.numeric(pattern_counts))
	
	# write the output
	outname <- paste0("unique_counts.", a, ".txt")
	write.table(output, outname, quote=F, row.names=F, sep="\t")

}

# get individual names
individuals <- colnames(x)

# change tip names
individuals[individuals == "C028__T_vicinus1_"] <- "vicinus"
individuals[individuals == "C049__herculeanus_"] <- "herculeanus"
individuals[individuals == "C125__laevissimus_"] <- "laevissimus"
individuals[individuals == "C126__modoc_east_"] <- "modoc_east"
individuals[individuals == "C130b__schaefferi_"] <- "schaefferi"
individuals[individuals == "C209__amcast_"] <- "americanus"
individuals[individuals == "C213__chromaiodes_"] <- "chromaiodes"
individuals[individuals == "C219__novaeboracensis_"] <- "novaeboracensis"
individuals[individuals == "C256__pennsylvanicus_"] <- "pennsylvanicus"
individuals[individuals == "C257__myrmentoma_"] <- "decipiens"
individuals[individuals == "C276__modoc_west_"] <- "modoc_west"
individuals[individuals == "C291__quercicola_"] <- "laevigatus"
individuals[individuals == "C303b__new_"] <- "new"
individuals[individuals == "C361__texanus_"] <- "texanus"

# add spaces after species names
for(a in 1:length(individuals)) {
	spaces <- paste0(rep(" ", 20 - nchar(individuals[a])), collapse = '')
	individuals[a] <- paste0(individuals[a], spaces)
}


# read in all unique combinations for each scaffold
x_files <- list.files(pattern="unique*")
x <- list()
for(a in 1:length(x_files)) {
	print(a)
	x[[a]] <- read.table(x_files[a], header=T)
}
x <- do.call(rbind, x)

# combine repeated strings
x_uniques <- unique(x$patterns)
x_counts <- rep(0, length(x_uniques))
for(a in 1:length(x_uniques)) {
	a_rep <- x[x$patterns == x_uniques[a],]
	x_counts[a] <- sum(a_rep$counts)
}

total_uniques <- data.frame(patterns=as.character(x_uniques), counts=as.numeric(x_counts))

# put the patterns back in a data frame of individuals
pattern_matrix <- matrix("X", nrow=nrow(total_uniques), ncol=length(individuals))
for(a in 1:nrow(total_uniques)) {
	pattern_matrix[a,] <- strsplit(total_uniques$patterns[a], "")[[1]]
}

# cat per individual
seqs <- rep("", length(individuals))
for(a in 1:length(individuals)) {
	seqs[a] <- paste0(pattern_matrix[,a], collapse='')
}



# cat the individuals and sequences
output_data <- paste0(individuals, seqs)

# define header
header <- paste0("     ", length(output_data), "     ", nchar(seqs[a]), "  P")

# write
write(header, file="camponotus.phy", ncolumns=1)
write(output_data, file="camponotus.phy", ncolumns=1, append=TRUE)
write("", file="camponotus.phy", ncolumns=1, append=TRUE)
write(total_uniques$counts, file="camponotus.phy", ncolumns=15, append=TRUE)










