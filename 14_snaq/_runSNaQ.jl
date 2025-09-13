#!/usr/bin/env julia

# command to run this: julia _runSNaQ.jl $SLURM_ARRAY_TASK_ID

using PhyloNetworks
using SNaQ
using PhyloPlots
using CSV
using DataFrames

boot_run = parse(Int, ARGS[1])

outputfile = string("bootsnaq_", boot_run)

# read tree
tre = readnewick("camponotus_focal_astral.tre")

# read in CF with confidence intervals
df = CSV.read("_CF_all_species.csv", DataFrame)

# define seed
seed = 1234 + boot_run

# run 1 bootstrap with 10 runs 
bootnet = bootsnaq(tre, df, hmax=2, nrep=1, seed=seed, filename=outputfile)







