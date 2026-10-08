# campphylo
cophylogenetic analysis of North American Camponotus and their endosymbionts, w/ comparative genomics of Blochmannia endosymbionts, and description of a new species

Description of scripts: \
00_setup.sh -> \
01_align_genotype.sh -> \
02_merge_vcf.sh -> \
03_filter_vcf.sh -> \
04_make_phylo_scripts.r -> \
05_stat_array.sh -> \
06_combine_phylogenies.r -> \
06b_combine_stats.sh -> \
07_prune_trees_for_twisst.r -> \
07_species_trees.sh -> \
08_twisst.sh -> \
09_align_genotype_blochmannia.sh -> \
10_merge_filter_blochmannia.sh -> \
11_make_fasta_blochmannia.r -> \
12_raxml_blochmannia.sh -> \
13_dsuite.sh -> \
14_snaq -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 01_make_mrbayes_script.r -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 02_mbsum.sh -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 03_bucky_array.sh -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 04_cat_bucky_CFs.r -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 05_merge_tree_files.r -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 06_astral_of_mrbayes_trees.sh -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 07_snaq.jl -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 08_bootsnaq.sh -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 09_cat_bootsnaq.sh -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> 10_summarize_bootsnaqs_on_tree.jl -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> _parse_concordance.r -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> _runSNaQ.jl -> \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-> _write_quartet.r -> \
15_vcf_to_matrix.sh -> \
16_convert_matrix_to_phylip_site_patterns.r -> \
17_mcmctree.sh -> \
18_minys.sh -> \
19_pgap.sh -> \
20_process_bloch_genomes.sh -> \
_vcf_to_matrix.r -> \
_window_stat_calculations.r -> \
_write_mrbayes.r -> \
contam_check.r -> \

All other files are helper or control files used in scripts.
