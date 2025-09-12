#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=bucky
#SBATCH --nodes=1 --ntasks=1
#SBATCH --partition nocona
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --array=1-100

source activate bcftools

# Set the number of runs that each SLURM task should do
PER_TASK=360

# Calculate the starting and ending values for this task based
# on the SLURM task and the number of runs per task.
START_NUM=$(( ($SLURM_ARRAY_TASK_ID - 1) * $PER_TASK + 1 ))
END_NUM=$(( $SLURM_ARRAY_TASK_ID * $PER_TASK ))

if [[ $END_NUM -gt 35960 ]]; then END_NUM=35960; fi

# Print the task and run range
echo This is task $SLURM_ARRAY_TASK_ID, which will do runs $START_NUM to $END_NUM

# Run the loop of runs for this task.
for (( run=$START_NUM; run<=$END_NUM; run++ )); do
	echo This is SLURM task $SLURM_ARRAY_TASK_ID, run number $run
	
	Rscript _write_quartet.r $run translate_table.txt
	
	bucky -a 10 -p run${run}.quartet -o run${run} /lustre/scratch/jmanthey/08_ant_phylo/11_mrbayes/windows/*in
	
	Rscript _parse_concordance.r run${run} $SLURM_ARRAY_TASK_ID
	
	rm run${run}.input

	rm run${run}.cluster

	rm run${run}.concordance

	rm run${run}.gene

	rm run${run}.out
	
	rm run${run}.quartet

done
