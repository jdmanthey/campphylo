# campphylo
cophylogenetic analysis of North American Camponotus and their endosymbionts, w/ comparative genomics of Blochmannia endosymbionts, and description of a new species

Description of scripts: \
00_setup.sh -> index reference and setup directory structure

01_align_genotype.sh -> filter, align, genotype each sample

02_merge_vcf.sh -> merge individuals' VCF files together

03_filter_vcf.sh -> filter VCF files for downstream analyses

04_make_phylo_scripts.r -> R script to create an array job to run RAxML

05_stat_array.sh -> estimate statistics in sliding windows, uses _window_stat_calculations.r script

06_combine_phylogenies.r -> combine window phylogenies to single file

06b_combine_stats.sh -> Combine windowed statistics output into single file. 

07_prune_trees_for_twisst.r -> Prune phylogenies for the subset of taxa used for TWISST.

07_species_trees.sh -> Estimate a species tree with ASTRAL and a maximum clade credibility tree.

08_twisst.sh -> Run TWISST on the phylogenies.

09_align_genotype_blochmannia.sh -> Filter, align, and genotype the Blochmanniella.

10_merge_filter_blochmannia.sh -> Merge the Blochmanniella VCFs and then filter them for downstream analyses.

11_make_fasta_blochmannia.r -> Make a FASTA file from the VCF for phylogenetics of the Blochmanniella.

12_raxml_blochmannia.sh -> Run RAxML for the symbiont alignment.

13_dsuite.sh -> Run DSUITE on the phylogenies.

14_snaq -> Directory of scripts to run SNAQ.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 01_make_mrbayes_script.r -> R script to make MrBayes SLURM submission script.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 02_mbsum.sh -> Run mbsum on the MrBayes output.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 03_bucky_array.sh -> Run BUCKY on the MrBayes outptu.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 04_cat_bucky_CFs.r -> Combine all the BUCKY concordance factors.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 05_merge_tree_files.r -> Merge all the tree files.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 06_astral_of_mrbayes_trees.sh -> Species tree of MrBayes output for starting tree.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 07_snaq.jl -> Run SNAQ.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 08_bootsnaq.sh -> Run SNAQ bootstraps.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 09_cat_bootsnaq.sh -> Combine the bootstrapping output.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 10_summarize_bootsnaqs_on_tree.jl -> Summarize the bootstraps on the network.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> _parse_concordance.r -> R script to parse the concordance factor output.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> _runSNaQ.jl -> Julia script to run SNAQ.\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> _write_quartet.r -> R script to write out quartets.

15_vcf_to_matrix.sh -> Uses _vcf_to_matrix.r to convert a VCF to a table of genotypes

16_convert_matrix_to_phylip_site_patterns.r -> Take all the genotype matrices and count the site patterns.

17_mcmctree.sh -> Run MCMCtree.

18_minys.sh -> Run the Mine Your Symbiont Pipeline to assemble Blochmanniella genomes.

19_pgap.sh -> Run the Prokaryote Genome Annotation Pipeline on the Blochmanniella assemblies.

20_process_bloch_genomes.sh -> Plot to summarize and plot the gene content and pangenome content of the Blochmanniella genomes.

_vcf_to_matrix.r -> Used in 15_vcf_to_matrix.sh to convert a vcf to a table of genotypes.

_window_stat_calculations.r -> used in 05_stat_array.sh to calculate sliding window statistics.

_write_mrbayes.r -> Helper script to write MrBayes input nexus files from a VCF.

contam_check.r -> Script to plot counts of alleles for each polymorphism, to check for frequencies suggestive of contamination.

All other files are helper or control files used in scripts.
