# all done interactively 
##################################
##################################
# part 1 - set up files for blast
##################################
##################################

R

options(scipen=999)
library(ape)

# list of pgap annotation output directories
x_files <- list.files(pattern="^output_*")
samples <- substr(x_files, 8, nchar(x_files))

# loop for each file to concatenate the fasta files and then the faa files

for(a in 1:length(x_files)) {
	# read in fasta and add it to the total fasta file
	a_fasta <- read.FASTA(list.files(x_files[a], pattern="\\.fasta", full.names=T))
	if(a == 1) { total_fasta <- a_fasta } else { total_fasta <- c(total_fasta, a_fasta)}
	
	# read in AA faa file
	a_faa <- read.FASTA(paste(x_files[a], "/annot.faa", sep=""), type="AA")
	
	# combine new names and annotations into table
	if(a == 1) {
		faa_gene_att <- cbind(paste(samples[a], seq(from=1, to=length(names(a_faa)), by=1), sep="__"), substr(names(a_faa), 26, nchar(names(a_faa)) - 28))
	} else {
		faa_gene_att <- rbind(faa_gene_att, cbind(paste(samples[a], seq(from=1, to=length(names(a_faa)), by=1), sep="__"), substr(names(a_faa), 26, nchar(names(a_faa)) - 28)))
	}
	
	# rename faa seqs
	names(a_faa) <- paste(samples[a], seq(from=1, to=length(names(a_faa)), by=1), sep="__")
	
	# add to final object
	if(a == 1) { total_faa <- a_faa } else { total_faa <- c(total_faa, a_faa)}
	
}

# write output
write.FASTA(total_fasta, file="_blochmannia_sequences_all.fasta")
write.FASTA(total_faa, file="_blochmannia_AA_all.fasta")
write.table(faa_gene_att, file="_bloch_gene_names.txt", quote=F, sep="\t", row.names=F, col.names=F)

quit()


##################################
##################################
# part 2 - BLAST
##################################
##################################
export BATCH_SIZE=10

makeblastdb -in _blochmannia_AA_all.fasta -dbtype  prot -out bloch_prot

blastp -query _blochmannia_AA_all.fasta -out _blochmannia_AA_all.blast -task blastp -db bloch_prot \
-outfmt "6 qseqid sseqid pident length evalue" -max_target_seqs 100 -evalue 0.1 -num_threads 10


##################################
##################################
# part 3 - analyze BLAST output
##################################
##################################


options(scipen=999)
library(ape)
library(phytools)
library(RColorBrewer)
library(stats)
library(gplots)
library(viridis)

# number of individuals
n_individuals <- 45

# read in proteins file
proteins <- read.FASTA("_blochmannia_AA_all.fasta", type="AA")

# read in blast results
blast <- read.table("_blochmannia_AA_all.blast", sep="\t", stringsAsFactors=F)
colnames(blast) <- c("query", "subject", "identity", "length", "e-value")

# problem with C284 (some repeated genes multiple times in assembly)-> remove this assembly
blast <- blast[sapply(strsplit(blast[,1], "__"), "[[", 1) != "C284",]
blast <- blast[sapply(strsplit(blast[,2], "__"), "[[", 1) != "C284",]

# pull out names of unique individuals in dataset
individuals <- unique(paste0(sapply(strsplit(blast[,2], "__"), "[[", 1), "__", sapply(strsplit(blast[,2], "__"), "[[", 2)))

# read in name convsersion table
name_table <- read.table("_bloch_gene_names.txt", sep="\t", stringsAsFactors=F, quote="")

# subset genes to >= 35% identity
blast <- blast[blast$identity >= 35,]

# duplicate blast object
blast2 <- blast

# outputs
# table of potential names for each gene
# matrix of potential genes
# while loop to go through and eliminate all genes

# if more matches than individuals, likely that one gene is similar to another
# so will need to pull out the matches with higher similarity per individual
queries <- list()
matches <- list()
potential_names <- list()
counter <- 1
while(nrow(blast2) > 0) {
	# print progress
	if(counter %% 50 == 0) { print(counter) }
	
	# subset to first query
	a_rep <- blast2[blast2$query == unique(blast2$query)[1], ]
	
	# remove matches less than 50% of query length
	a_rep <- a_rep[a_rep$length >= a_rep$length[1] / 2,]
	
	queries[[counter]] <- a_rep$query[1]
	
	# identify any large breaks in similarity and remove the lesser matched portion
	a_diffs <- c(diff(a_rep$identity), 0)
	a_diffs <- seq(from=1, to=length(a_diffs), by=1)[a_diffs < -30]
	if(length(a_diffs > 0)) {
		a_rep <- a_rep[1:a_diffs,]
	}
	
	
	# check if there are more than one match per individual
	# if more than one match, remove outliers
	if(length(sapply(strsplit(a_rep[,2], "__"), "[[", 1)) != length(unique(sapply(strsplit(a_rep[,2], "__"), "[[", 1)))) {
		# find the interquartile distance and multiply by 1.5 to find potential outliers
		a_summary <- as.numeric(summary(a_rep$identity))
		a_IQR <- a_summary[5] - a_summary[2]
		a_lower <- a_summary[2] - (1.5 * a_IQR)
		# remove outliers
		a_rep <- a_rep[a_rep$identity > a_lower,]
		
		# recheck if there are any duplicates and throw error if there are
		if(length(sapply(strsplit(a_rep[,2], "__"), "[[", 1)) != length(unique(sapply(strsplit(a_rep[,2], "__"), "[[", 1)))) {
			print(counter)
			stop("still duplicates in matches, filter these out")
		}
 	} 
	
	# pull out potential gene names
	a_gene_names <- name_table[name_table[,1] %in% a_rep$subject[a_rep$query == a_rep$query[1]],2]
	# add to list as table
	a_output <- data.frame(gene=as.numeric(rep(counter, length(unique(a_gene_names)))),
				gene_names=as.character(names(table(a_gene_names))), gene_counts=as.numeric(table(a_gene_names)))
	potential_names[[counter]] <- a_output	
	
	# pull out matches
	a_matches <- paste0(sapply(strsplit(a_rep[,2], "__"), "[[", 1), "__", sapply(strsplit(a_rep[,2], "__"), "[[", 2))
	matches[[counter]] <- a_matches
	
	# remove query and matches from blast2 object
	blast2 <- blast2[blast2$query != a_rep[1,1] & blast2$subject != a_rep[1,1],]
	blast2 <- blast2[blast2$query %in% a_rep$subject == FALSE,]	
	blast2 <- blast2[blast2$subject %in% a_rep$subject == FALSE,]	
	
	# add one to counter 
	counter <- counter + 1
}

# check that counts and number of names matches
# any deviations will print the index a
for(a in 1:length(matches)) {
	a_matches <- matches[[a]]
	a_names <- potential_names[[a]]
	if(sum(a_names$gene_counts) != length(a_matches)) {
		print(a)
	}
}

# histogram of number of potential names for each gene
n_names <- c()
for(a in 1:length(potential_names)) {
	n_names <- c(n_names, nrow(potential_names[[a]]))
}
hist(n_names, breaks=seq(from=1, to=max(n_names), by=1))

# add a duplicate of potential names
potential_names2 <- potential_names

# process all gene names 
# remove hypothetical 
# combine multiple gene namings for inspection
for(a in 1:length(potential_names)) {
	a_rep <- potential_names[[a]]
	a_rep <- a_rep[grep("hypothetical", a_rep[,2], invert=T),]
	potential_names2[[a]] <- a_rep
}
# further refine gene names
gene_names <- c()
for(a in 1:length(potential_names2)) {
	a_rep <- potential_names2[[a]]
	if(nrow(a_rep) > 1) { # more than one name
		a_rep <- a_rep[order(a_rep$gene_counts, decreasing=T),]
		a_rep <- paste(a_rep$gene_names, collapse=" ||| ")
	} else if(nrow(a_rep) == 1) { # only one name
		a_rep <- a_rep$gene_names
	} else { # no names
		a_rep <- "no name"
	}
	gene_names <- c(gene_names, a_rep)
}

# make an empty gene matrix (all zeros)
# make an empty data frame with the products as row names
gene_matrix <- matrix(0, nrow=length(gene_names), ncol=n_individuals)
rownames(gene_matrix) <- gene_names
colnames(gene_matrix) <- individuals
head(gene_matrix)

# fill in matrix
for(a in 1:nrow(gene_matrix)) {
	for(b in 1:ncol(gene_matrix)) {
		if(individuals[b] %in% matches[[a]]) {gene_matrix[a,b] <- 1}
	}
}

# write output and manually inspect (possibly merge those that were too distantly blast related to automatically match)
# also remove hypothetical proteins
write.table(gene_matrix, file="_gene_pa_matrix.txt", sep="\t", quote=F)



###################################
## Plotting
###################################

x <- read.table("_gene_pa_matrix_edited.txt", sep="\t", row.names=1, quote="", stringsAsFactors=F, header=T)


# heatmap of gene presence / absence correlations
library(gplots)
library(viridis)
mycolors <- cividis(n = 200, alpha = 1, begin = 0, end = 1, direction = -1)

pdf(file="_bloch_genes_heatmap.pdf", height=10, width=10)
heatmap.2(cor(x), trace = "none", col = mycolors, density.info="none")
dev.off()




# core / pan genome
# identify size of core / total genome
# 100 replicates
replicates <- 100
# number of individuals
n_individuals <- 45

core <- matrix(0, nrow=replicates, ncol=n_individuals)
pan <- matrix(0, nrow=replicates, ncol=n_individuals)
colnames(core) <- colnames(pan) <- seq(from=1, to=n_individuals, by=1)
rownames(core) <- rownames(pan) <- seq(from=1, to=replicates, by=1)
for(a in 1:replicates) {
	for(b in 1:ncol(core)) {
		b_rep <- as.matrix(x[,sample(seq(from=1, to=ncol(x), by=1), b)])
		if(b == 1) {
			core[a,b] <- pan[a,b] <- sum(b_rep)
		} else {
			# core
			core[a,b] <- sum(as.numeric(apply(b_rep, 1, min)))
			# pan
			pan[a,b] <- sum(as.numeric(apply(b_rep, 1, max)))
		}
	}
}

par(mar=c(5,5,1,1))
plot(c(-1,-1), cex=0.1, col="white", xlim=c(0, n_individuals), ylim=c(520, 620), ylab="Number of Genes", xlab="Number of Genomes")

mycolors <- mako(n = 10, alpha = 1, begin = 0, end = 1, direction = -1)

pan_col <- mycolors[3]
core_col <- mycolors[8]


# plot ranges for each value
for(a in 1:ncol(pan)) {
	lines(c(a, a), c(min(core[,a]), max(core[,a])), col=core_col, lwd=0.5)
	lines(c(a, a), c(min(pan[,a]), max(pan[,a])), col=pan_col, lwd=0.5)
}
# plot means
points(apply(pan, 2, mean), col=pan_col, pch=19)
points(apply(core, 2, mean), col=core_col, pch=21)





# plot genome size vs. gene content
individuals <- colnames(x)
n_genes <- c()
genome_size <- c()
# pull out number genes and genome size for each individual
for(a in 1:length(individuals)) {
	# number genes
	n_genes <-c(n_genes, sum(x[,colnames(x) == individuals[a]]))
	# genome size
	a_rep <- scan(paste0(individuals[a], ".fasta"), what="character")
	a_rep <- a_rep[2:length(a_rep)]
	a_rep <- paste0(a_rep, collapse="")
	genome_size <- c(genome_size, nchar(a_rep))
}
output <- data.frame(individuals=as.character(individuals), n_genes=as.numeric(n_genes), genome_size=as.numeric(genome_size))

library(RColorBrewer)
choose_dark_colors <- colorRampPalette(brewer.pal(8, "Dark2"))(20)

par(mar=c(5,5,1,1))
plot(output$genome_size, output$n_genes, xlab="Genome Size", ylab="Number of Genes", pch=19, cex=0.1, col="white")

species <- unique(sapply(strsplit(output$individuals, "__"), "[[", 2))
for(a in 1:length(species)) {
	a_rep <- output[sapply(strsplit(output$individuals, "__"), "[[", 2) == species[a],]
	points(a_rep$genome_size, a_rep$n_genes, pch=19, cex=1, col=choose_dark_colors[a])
}











