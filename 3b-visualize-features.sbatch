#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=0:10:00
#SBATCH --qos=normal
#SBATCH --partition=amilan
#SBATCH --job-name=qiime-visualize-features
#SBATCH --mail-user=dcking@colostate.edu
#SBATCH --mail-type=END,FAIL,INVALID_DEPEND
#SBATCH --output=%x.%j.log # gives slurm.ID.log
echo "$0 $(date)"
module load qiime2/2026.1_amplicon # need this version for sk-learn 1.4.2

TMP=$SLURM_SCRATCH
input=taxonomy_greengenes.qza
output=taxonomy_greengenes.qzv

cmd="qiime metadata tabulate \
         --m-input-file ${input} \
         --o-visualization ${output}"
echo $cmd
time eval "$cmd"
