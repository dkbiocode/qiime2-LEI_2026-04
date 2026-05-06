#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --time=0:10:00
#SBATCH --qos=testing
#SBATCH --partition=atesting
#SBATCH --job-name=nf-slurm
#SBATCH --mail-user=dcking@colostate.edu
#SBATCH --mail-type=END,FAIL,INVALID_DEPEND
#SBATCH --output=%x.%j.log # gives slurm.ID.log
#hash qiime 2>/dev/null || module load qiime2/2026.1_amplicon
hash nextflow 2>/dev/null || module load nextflow


nextflow run main.nf -resume -entry import_data -profile slurm  # -stub-run -resume
