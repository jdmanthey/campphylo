cd /lustre/scratch/jmanthey/09_antphylo/05_filtered_vcf/windows

# combine the output for different analyses into a single file each
# first add a header for each file
grep 'pop1' scaffold0001__100001__200000__stats.txt > ../window_heterozygosity.txt
grep 'pop1' scaffold0001__100001__200000__stats.txt > ../window_Dxy.txt
grep 'pop1' scaffold0001__100001__200000__stats.txt > ../window_Fst.txt

# add the relevant stats to each file
for i in $( ls *stats.txt ); do grep 'heterozygosity' $i >> ../window_heterozygosity.txt; done
for i in $( ls *stats.txt ); do grep 'Dxy' $i >> ../window_Dxy.txt; done
for i in $( ls *stats.txt ); do grep 'Fst' $i >> ../window_Fst.txt; done

