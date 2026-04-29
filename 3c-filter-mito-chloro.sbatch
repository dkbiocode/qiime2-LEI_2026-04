#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=0:10:00
#SBATCH --qos=normal
#SBATCH --partition=amilan
#SBATCH --job-name=qiime-filter-mito-chloro
#SBATCH --mail-user=dcking@colostate.edu
#SBATCH --mail-type=END,FAIL,INVALID_DEPEND
#SBATCH --output=%x.%j.log # gives slurm.ID.log
echo "$0 $(date)"
module load qiime2/2026.1_amplicon # need this version for sk-learn 1.4.2

TMP=$SLURM_SCRATCH
input=taxonomy_greengenes.qza
output=taxonomy_greengenes.qzv

taxonomy=taxonomy_greengenes.qza
table=2-table.qza
output=samples_filter_taxa_greengenes.qza

cmd="qiime taxa filter-table \
        --i-table ${table} \
        --i-taxonomy ${taxonomy} \
        --p-exclude mitochondria,chloroplast \
        --o-filtered-table ${output}"
echo $cmd
time eval "$cmd"

