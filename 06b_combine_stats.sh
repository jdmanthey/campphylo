cd /lustre/scratch/jmanthey/08_ant_phylo/33_stats

# combine the output for different windows into a single file 
# first add a header for each file
grep 'pop1' scaffold0001__10000001__10050000__stats.txt > ../window_stats.txt

# add the stats to the file
for i in $( ls *stats.txt ); do grep -v 'pop1' $i >> ../window_stats.txt; done
