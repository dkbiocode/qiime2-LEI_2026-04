#!/usr/bin/env bash
set -eu
threads=$(nproc)

# Step 1: dada2 denoise
input_qza=demux.qza
# OUTPUT
rep_seqs_qza=2-repseqs.qza
stats_qza=2-stats.qza
table=2-table.qza


# Step 3: feature-table tabulate-seqs

rep_seqs_qzv=${rep_seqs_qza/.qza/.qzv}

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
    --o-table ${table}"
echo $cmd
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
echo $cmd
time eval $cmd

exit 0

# STEP 3: feature-table SUMMARIZE:
if [ -e metadata.txt ]
then
    echo "metadata.txt already exists. Rename or delete to recreate it."
else
    echo "sample_id" > metadata.txt
    cmd="ls Fastq/*_R1_001.fastq.gz \
    | xargs -n1 basename \
    | sed 's/_S[0-9]*_L001_R1_001.fastq.gz//' \
    >> metadata.txt"
    echo "$cmd"
    eval "$cmd"

    echo "Created metadata.txt"
    cat metadata.txt
fi
cmd="qiime feature-table summarize \
        --i-table {input.table} \
        --m-sample-metadata-file {input.metadata} \
        --o-visualization {output}"


# STEP 4: TABULATE_SEQS:
    # input:
    #     f"{WORK_DIR}/02_repSeqs_mouse_fecal_samples.qza"
    # output:
    #     f"{WORK_DIR}/02_repSeqs_mouse_fecal_samples.qzv"
cmd="qiime feature-table tabulate-seqs \
    --i-data {input} \
    --o-visualization {output}"
echo $cmd