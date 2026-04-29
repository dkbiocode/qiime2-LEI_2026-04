#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=0:10:00
#SBATCH --qos=normal
#SBATCH --partition=amilan
#SBATCH --job-name=qiime-taxonomy-barblot
#SBATCH --mail-user=dcking@colostate.edu
#SBATCH --mail-type=END,FAIL,INVALID_DEPEND
#SBATCH --output=%x.%j.log # gives slurm.ID.log
date

module load qiime2/2026.1_amplicon # need this version for sk-learn 1.4.2


cmd="qiime taxa barplot \
    --i-table 2-table.qza \
    --i-taxonomy taxonomy_greengenes.qza\
    --m-metadata-file metadata.txt \
    --o-visualization taxa-bar-plots.qzv"

echo $cmd
time eval "$cmd"
