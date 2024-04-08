#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=twisst
#SBATCH --nodes=1 --ntasks=2
#SBATCH --partition quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G

python /home/jmanthey/twisst/twisst.py -t camponotus_100kbp_pruned.trees.gz -w output.weights.csv.gz --outputTopos output_topologies.trees \
-g modoc_east -g modoc_west -g new -g herculeanus -g novaeboracencis -g chromaiodes -g pennsylvanicus \
-g laevissimus --outgroup laevissimus --method complete --groupsFile twisst_groups.txt

#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=twisst2
#SBATCH --nodes=1 --ntasks=2
#SBATCH --partition quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G

python /home/jmanthey/twisst/twisst.py -t camponotus_100kbp_pruned.trees.gz -w output2.weights.csv.gz --outputTopos output_topologies2.trees \
-g herc_group -g penn_group -g new \
-g laevissimus --outgroup laevissimus --method complete --groupsFile twisst_groups2.txt


