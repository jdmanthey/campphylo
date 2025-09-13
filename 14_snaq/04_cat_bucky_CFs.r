options(scipen=999)

# read snaq mapping file
sm <- read.table("snaq_mapping.csv", header=T, sep=",")

# get unique species
species <- unique(sm[,1])

# list the CF files
cf_files <- list.files(pattern="*_CF.txt")

# cat all the CF files
cf_all <- list()
for(a in 1:length(cf_files)) {
	cf_all[[a]] <- read.table(cf_files[a])
}
cf_all <- do.call(rbind, cf_all)

# edit the ngene column (some are rounded 0.001 off)
cf_all[,14] <- round(mean(cf_all[,14]))

# add column names
colnames(cf_all) <- c("t1", "t2", "t3", "t4", "CF12_34", "CF12_34_lo", "CF12_34_hi", "CF13_24", "CF13_24_lo", "CF13_24_hi", "CF14_23", "CF14_23_lo", "CF14_23_hi", "ngenes")

# write output
write.table(cf_all, file="_CF_all_individuals.csv", row.names=F, quote=F, sep=",")

# convert individual names to species names 
for(a in 1:length(species)) {
	a_sm <- sm[sm[,1] == species[a],]
	# rename the taxa 1 through 4 in the CF table
	for(b in 1:nrow(a_sm)) {
		cf_all$t1[cf_all$t1 == a_sm[b,2]] <- a_sm[b,1]
		cf_all$t2[cf_all$t2 == a_sm[b,2]] <- a_sm[b,1]
		cf_all$t3[cf_all$t3 == a_sm[b,2]] <- a_sm[b,1]
		cf_all$t4[cf_all$t4 == a_sm[b,2]] <- a_sm[b,1]
	}
}

# combine to summary per species in quartets with a single species not appearing twice in a quartet
combos <- unique(cf_all[,1:4])
keep <- rep(TRUE, nrow(combos)) # counter to determine which combos to keep
for(a in 1:nrow(combos)) {
	a_rep <- unique(as.character(combos[a,]))
	if(length(a_rep) != 4) {keep[a] <- FALSE}
}
combos <- combos[keep,]

# summarize the CFs per quartet and write to output
for(a in 1:nrow(combos)) {
	a_rep <- cf_all[cf_all$t1 == combos[a,1] & cf_all$t2 == combos[a,2] & cf_all$t3 == combos[a,3] & cf_all$t4 == combos[a,4],]
	# summarize each column and modify the first row of the temp data frame
	a_rep$CF12_34[1] <- mean(a_rep$CF12_34)
	a_rep$CF13_24[1] <- mean(a_rep$CF13_24)
	a_rep$CF14_23[1] <- mean(a_rep$CF14_23)
	a_rep$CF12_34_lo[1] <- min(a_rep$CF12_34_lo)
	a_rep$CF13_24_lo[1] <- min(a_rep$CF13_24_lo)
	a_rep$CF14_23_lo[1] <- min(a_rep$CF14_23_lo)
	a_rep$CF12_34_hi[1] <- max(a_rep$CF12_34_hi)
	a_rep$CF13_24_hi[1] <- max(a_rep$CF13_24_hi)
	a_rep$CF14_23_hi[1] <- max(a_rep$CF14_23_hi)
	# keep only first row and write to file
	a_rep <- a_rep[1,]
	if(a == 1) {
		write.table(a_rep, file="_CF_all_species.csv", row.names=F, quote=F, sep=",")
	} else {
		write.table(a_rep, file="_CF_all_species.csv", row.names=F, col.names=F, quote=F, sep=",", append=T)
	}
}

