#!/usr/bin/env bash

# the input path must only contain the read files (no I files, metadata, etc.)
cmd="qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path Fastq \
    --input-format CasavaOneEightSingleLanePerSampleDirFmt \
    --output-path demux.qza"

echo $cmd
time eval "$cmd"