#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=1:00:00
#SBATCH --qos=normal
#SBATCH --partition=amilan
#SBATCH --job-name=qiime-import
#SBATCH --mail-user=dcking@colostate.edu
#SBATCH --mail-type=END,FAIL,INVALID_DEPEND
#SBATCH --output=%x.%j.log # gives slurm.ID.log
module load qiime2/2026.1_amplicon # need this version for sk-learn 1.4.2

set -eu
source shared.sh # defines echo_[color]

# the input path must only contain the read files (no I files, metadata, etc.)
cmd="qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path Fastq \
    --input-format CasavaOneEightSingleLanePerSampleDirFmt \
    --output-path demux.qza"

echo $cmd
#time eval "$cmd"

cmd="qiime demux summarize \
    --i-data demux.qza \
    --o-visualization demux_summary.qzv"

echo $cmd
time eval "$cmd"
