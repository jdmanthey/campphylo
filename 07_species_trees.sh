# maximum clade credibility tree
sumtrees.py --output=camponotus_50kbp.tre --min-clade-freq=0.01 camponotus_50kbp.trees

# coalescent tree of all gene trees using ASTRAL III
# automatically calculates local branch support using quartets, described here: https://doi.org/10.1093/molbev/msw079
java -jar ~/Astral/astral.5.6.3.jar -i camponotus_50kbp.trees -o camponotus_50kbp.tre 2> camponotus_50kbp_astral.log
