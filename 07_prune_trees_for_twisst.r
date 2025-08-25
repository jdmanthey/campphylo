library(ape)

options(scipen=999)

x <- read.tree("camponotus_50kbp.trees")

tips_to_keep <- scan("focal_group.txt", what="character")

for(a in 1:length(x)) {
	x[[a]] <- keep.tip(x[[a]], tips_to_keep)
}

write.tree(x, file="camponotus_50kbp_pruned.trees")

x <- read.tree("camponotus_50kbp.trees")

tips_to_keep <- scan("herc_group.txt", what="character")

for(a in 1:length(x)) {
	x[[a]] <- keep.tip(x[[a]], tips_to_keep)
}

write.tree(x, file="camponotus_50kbp_hercgroup.trees")

