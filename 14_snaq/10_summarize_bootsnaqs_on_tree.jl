using PhyloNetworks
using SNaQ
using PhyloPlots
using CSV
using DataFrames

# read in network
net2 = readnewick("net2_snaq.out") 

# root
rootatnode!(net2, "laevissimus")

# read bootsnaq
bootnet = readmultinewick("bootsnaq.out")

# bootstrap summary of tree edges
BSe_tree, tree1 = treeedges_support(bootnet,net2)

# show matrix of edges support
show(BSe_tree, allrows=true)

# summarize bootstrap frequencies of nodes, edges, and clade makeup
BSn, BSe, BSc, BSgam, BSedgenum = hybridclades_support(bootnet, net2);

# plot the bootstrap support of the hybrid edges (in this case 100 support for both)
plot(net2, edgelabel=BSe[!,[:edge,:BS_hybrid_edge]]);
