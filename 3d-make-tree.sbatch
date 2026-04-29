#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --time=0:10:00
#SBATCH --qos=normal
#SBATCH --partition=amilan
#SBATCH --job-name=qiime-make-tree
#SBATCH --mail-user=dcking@colostate.edu
#SBATCH --mail-type=END,FAIL,INVALID_DEPEND
#SBATCH --output=%x.%j.log # gives slurm.ID.log
date

module load qiime2/2026.1_amplicon # need this version for sk-learn 1.4.2

repseqs=2-repseqs.qza

cmd="qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences ${repseqs} \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza \
  --p-n-threads ${SLURM_NTASKS}"

echo $cmd
time eval "$cmd"
