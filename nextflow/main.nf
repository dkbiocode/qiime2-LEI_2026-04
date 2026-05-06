#!/usr/bin/env nextflow
nextflow.enable.dsl=2

workDir="/scratch/alpine/${USER}"
// you must run this workflow in two phases:
// PHASE I. nextflow run main.nf -entry import_data
// Inspect the generated file stored in params.demux_summary_qzv at https://view.qiime2.org to determine if the reads need to be trimmed.
// See the note below about TRUNCATION PARAMETERS on how to interpret the base quality falloffs and how to trim adapters if they are present.
// PHASE 2. nextflow run main.nf -entry main
// This runs the rest of the pipeline


// PHASE I processes
process FASTP {
    tag "${sample_id}"
    publishDir params.results_fastp, mode: 'link'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_fastp.json")

    script:
    """
    fastp \
      --in1 ${reads[0]} \
      --in2 ${reads[1]} \
      --out1 discard_R1.fastq.gz \
      --out2 discard_R2.fastq.gz \
      --json ${sample_id}_fastp.json \
      --cut_mean_quality 32 \
      --thread \$(nproc)

    rm discard_R*.fastq.gz
    """
}

process IMPORT_DATA {
    publishDir params.results_demux, mode: 'link'

    input:
    path fastq_dir

    output:
    path "${params.demux_qza}"

    script:
    """
    qiime tools import \
    --type '${params.read_type}' \
    --input-path ${fastq_dir} \
    --input-format '${params.read_format}' \
    --output-path ${params.demux_qza}
    """
}

process DEMUX_SUMMARIZE {
    publishDir params.results_demux, mode: 'link'

    input:
    path demux_qza

    output:
    path "${params.demux_summary_qzv}"

    script:
    """
    qiime demux summarize \
      --i-data ${demux_qza} \
      --o-visualization ${params.demux_summary_qzv}
    """
}

// PHASE II processes

process DENOISE {
    publishDir params.results_denoise, mode: 'link'

    input:
    path input_qza

    output:
    path "${params.dada2_rep_seqs}", emit: rep_seqs
    path "${params.dada2_stats}", emit: denoise_stats
    path "${params.dada2_base_trans_stats}", emit: base_trans_stats
    path "${params.dada2_table}", emit: denoise_table

    script:
    """
    qiime dada2 denoise-paired \
      --i-demultiplexed-seqs ${input_qza} \
      --p-trim-left-f ${params.trim_left_f} \
      --p-trim-left-r ${params.trim_left_r} \
      --p-trunc-len-r ${params.trunc_len_r} \
      --p-trunc-len-f ${params.trunc_len_f} \
      --p-n-threads \$(nproc) \
      --o-representative-sequences ${params.dada2_rep_seqs} \
      --o-denoising-stats ${params.dada2_stats} \
      --o-base-transition-stats ${params.dada2_base_trans_stats} \
      --o-table ${params.dada2_table}
    """
}

process METADATA_TABULATE {
    input:
    path stats_qza

    output:
    path "${params.stats_qzv}"

    script:
    """
    qiime metadata tabulate \
      --m-input-file ${stats_qza}  \
      --o-visualization ${params.stats_qzv}"
    """
}

process FEATURE_TABLE_SUMMARIZE {

    input:
    path table

    output:
    path "feature-frequencies.qza"
    path ""

    script:
    """
    qiime feature-table summarize \
      --i-table ${table} \
      --m-metadata-file metadata.txt \
      --o-summary ${summarize_qvz} \
      --o-feature-frequencies feature-frequencies.qza \
      --o-sample-frequencies sample-frequencies.qza
    """
}

workflow import_data {
    // file pairs for fastp (omit S#)
    def pattern = "*_S*_L001_R{1,2}_001.fastq.gz"

    fp_paired_ch = Channel.fromFilePairs("${params.fastq_dir}/${pattern}") { file ->
        // Extract the first part before the first underscore
        def matcher = (file.name =~ /^(.+?)_S.+/)
        return matcher ? matcher[0][1] : file.baseName
    }
    fp_paired_ch | FASTP
    fastq_ch = Channel.fromPath(params.fastq_dir, type: 'dir')
    IMPORT_DATA(fastq_ch)
    DEMUX_SUMMARIZE(IMPORT_DATA.out)
}

workflow analysis {
    demux_ch = Channel.fromPath("${params.results_demux}/${params.demux_qza}", checkIfExists: true)
    DENOISE(demux_ch)
}
