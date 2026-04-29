#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --time=1:00:00
#SBATCH --qos=normal
#SBATCH --partition=amilan
#SBATCH --job-name=qiime-classify-features
#SBATCH --mail-user=dcking@colostate.edu
#SBATCH --mail-type=END,FAIL,INVALID_DEPEND
#SBATCH --output=%x.%j.log # gives slurm.ID.log

module load qiime2/2026.1_amplicon # need this version for sk-learn 1.4.2

repseqs=2-repseqs.qza
backbone=greengenes_2024.09/2024.09.backbone.v4.nb.qza
output=taxonomy_greengenes.qza

cmd="qiime feature-classifier classify-sklearn \
  --i-reads ${repseqs} \
  --i-classifier ${backbone} \
  --p-n-jobs ${SLURM_NTASKS} \
  --o-classification ${output}"

echo $cmd
time eval $cmd
