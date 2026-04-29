#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --time=0:10:00
#SBATCH --qos=normal
#SBATCH --partition=amilan
#SBATCH --job-name=qiime-diversity
#SBATCH --mail-user=dcking@colostate.edu
#SBATCH --mail-type=END,FAIL,INVALID_DEPEND
#SBATCH --output=%x.%j.log # gives slurm.ID.log
date

module load qiime2/2026.1_amplicon # need this version for sk-learn 1.4.2
cmd="qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table 2-table.qza \
  --p-sampling-depth 80000 \
  --m-metadata-file metadata.txt \
  --output-dir core-metrics-results"


echo $cmd

time eval $cmd
