using PhyloNetworks
using SNaQ
using PhyloPlots
using CSV
using DataFrames

# read in CFs
buckyCF = readtableCF("_CF_all_species.csv")

# read tree
tre = readnewick("camponotus_focal_astral.tre")

# run SNAQ
net0 = snaq!(tre, buckyCF, hmax=0, runs=10, filename="net0_snaq")
net1 = snaq!(net0, buckyCF, hmax=1, runs=10, filename="net1_snaq")
net2 = snaq!(net1, buckyCF, hmax=2, runs=10, filename="net2_snaq")
net3 = snaq!(net2, buckyCF, hmax=3, runs=10, filename="net3_snaq")
net4 = snaq!(net3, buckyCF, hmax=4, runs=10, filename="net4_snaq")

# look at network files to check pseudo-likelihoods and choose which 
# network(s) to plot and bootstrap

# will visualize networks with 1-2 hybridizations (net1, net2)

# read in network
net1 = readnewick("net1_snaq.out") 
net2 = readnewick("net2_snaq.out") 


# root
rootatnode!(net1, "laevissimus")
rootatnode!(net2, "laevissimus")

# plot
plot(net1, showgamma=true);
plot(net2, showgamma=true);




