options(scipen=999)

# input args <- input file, popmap
args <- commandArgs(trailingOnly = TRUE)

# read translate table
tt <- read.table(args[2])

# get the run number
rn <- as.numeric(args[1])

# get all possible quartets
combos <- combn(seq(from=1, to=nrow(tt), by=1), 4)

# get the quartet for this run
combo <- combos[,rn]

# pull out this quartet from the translate table
combo_tt <- paste0("\t", rownames(tt)[combo], "\t", tt[combo,])

# modify the final individual to end the translate table
combo_tt[4] <- paste0(substr(combo_tt[4], 1, nchar(combo_tt[4]) - 1), ";")

# add the translate header
combo_tt <- c("translate", combo_tt)

# write output
outname <- paste0("run", rn, ".quartet")
write(combo_tt, file=outname, ncolumns=1)
