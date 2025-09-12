options(scipen=999)

# input args <- input file, popmap
args <- commandArgs(trailingOnly = TRUE)

# read bucky output
x <- scan(paste0(args[1], ".concordance"), what="character", sep="\t")

# keep the translated quartet
quartet <- x[2:5]
# edit to just get individual names
quartet <- substr(quartet, 4, nchar(quartet) - 1)

# keep only bottom sections of file
x <- x[grep("All Splits", x):length(x)]

# get order of splits
splits <- x[grep("\\{", x)]

# pull out number loci
nl <- x[grep("number of loci", x)]
nl <- sapply(strsplit(nl, "= "), "[[", 2)
nl <- sum(as.numeric(sapply(strsplit(nl, " \\("), "[[", 1)))

# mean CF
meanCF <- x[grep("mean CF", x)]
meanCF <- sapply(strsplit(meanCF, "   "), "[[", 2)
meanCF <- as.numeric(sapply(strsplit(meanCF, " \\("), "[[", 1))

# 95% CI CF low
lowCF <- x[grep("95% CI for CF", x)]
lowCF <- sapply(strsplit(lowCF, "\\("), "[[", 2)
lowCF <- sapply(strsplit(lowCF, "\\)"), "[[", 1)
lowCF <- as.numeric(sapply(strsplit(lowCF, ","), "[[", 1))
lowCF <- lowCF / nl

# 95% CI CF high
highCF <- x[grep("95% CI for CF", x)]
highCF <- sapply(strsplit(highCF, "\\("), "[[", 2)
highCF <- sapply(strsplit(highCF, "\\)"), "[[", 1)
highCF <- as.numeric(sapply(strsplit(highCF, ","), "[[", 2))
highCF <- highCF / nl

# combine the CF info with the quartets
combined <- data.frame(splits=as.character(splits), meanCF=as.numeric(meanCF), lowCF=as.numeric(lowCF), highCF=as.numeric(highCF))
# sort
combined <- combined[order(combined$splits),]

# order of output:
# taxon1	 taxon2	taxon3	taxon4	CF12.34	CF12.34_lo	CF12.34_hi	
# CF13.24	CF13.24_lo	CF13.24_hi	CF14.23	CF14.23_lo	CF14.23_hi	ngenes
output <- c(quartet, as.character(combined[1,2:4]), as.character(combined[2,2:4]),as.character(combined[3,2:4]), as.character(nl))

# write output
outname <- paste0("run", args[2], "_CF.txt")
write(output, file=outname, ncolumns=14, append=T)



