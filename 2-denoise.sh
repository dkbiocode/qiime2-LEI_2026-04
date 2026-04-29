#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=1:00:00
#SBATCH --qos=normal
#SBATCH --partition=amilan
#SBATCH --job-name=qiime-denoise
#SBATCH --mail-user=dcking@colostate.edu
#SBATCH --mail-type=END,FAIL,INVALID_DEPEND
#SBATCH --output=%x.%j.log # gives slurm.ID.log
module load qiime2/2026.1_amplicon # need this version for sk-learn 1.4.2

set -eu
source shared.sh # defines echo_[color]

threads=$(nproc)

# Step 1: dada2 denoise
input_qza=demux.qza
# OUTPUT
rep_seqs_qza=2-repseqs.qza
stats_qza=2-stats.qza
table=2-table.qza

# STEP 1: DENOISE
cmd="qiime dada2 denoise-paired \
    --i-demultiplexed-seqs ${input_qza} \
    --p-trim-left-f 0 \
    --p-trim-left-r 0 \
    --p-trunc-len-r 230 \
    --p-trunc-len-f 220 \
    --p-n-threads ${threads} \
    --o-representative-sequences ${rep_seqs_qza} \
    --o-denoising-stats ${stats_qza} \
    --o-base-transition-stats base-transition-stats.qza \
    --o-table ${table}"
echo_grey $cmd
#time eval $cmd

# STEP 2: TABULATE
# INPUT from step 1:
# -----------------
# stats_qza
#
# OUTPUT:
# ------------------
stats_qzv=${stats_qza/.qza/.qzv}

cmd="qiime metadata tabulate \
    --m-input-file ${stats_qza}  \
    --o-visualization ${stats_qzv}"
echo_grey $cmd
#time eval $cmd

# STEP 3: feature-table SUMMARIZE:
summarize_qvz="summarize.qzv"
if [ -e metadata.txt ]
then
    echo_yellow "metadata.txt already exists. Rename or delete to recreate it."
else
    echo -e "sampleid\tdescription" > metadata.txt
    cmd="ls Fastq/*_R1_001.fastq.gz \
    | xargs -n1 basename \
    | sed 's/_S[0-9]*_L001_R1_001.fastq.gz//' \
    | awk '{print \$0\"\tna\"}' >> metadata.txt"
    echo_grey "$cmd"
    eval "$cmd"

    echo_green "Created metadata.txt"
    echo -e "\033[0;90m"
    cat metadata.txt
    echo -e "\033[0m"
fi
cmd="qiime feature-table summarize \
        --i-table ${table} \
        --m-metadata-file metadata.txt \
        --o-summary ${summarize_qvz} \
        --o-feature-frequencies feature-frequencies.qza \
        --o-sample-frequencies sample-frequencies.qza"


echo_grey "$cmd"
time eval "$cmd"


# STEP 4: TABULATE_SEQS:
# INPUT: rep_seqs_qza # from step 1: --o-representative-sequences ${rep_seqs_qza}
# OUTPUT
rep_seqs_qzv=${rep_seqs_qza/.qza/.qzv}

cmd="qiime feature-table tabulate-seqs \
    --i-data ${rep_seqs_qza} \
    --o-visualization ${rep_seqs_qzv}"
echo_grey $cmd
time eval "$cmd"
