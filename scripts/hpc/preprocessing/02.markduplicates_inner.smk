#!/usr/bin/env python

SAMPLES=[i.strip() for i in open('../00.rawdata/rawfiles/inner_reefs.txt','rt').readlines()]

rule all:
    input:
        expand("mapping/{sample}_aligned_unsorted_duplicates_marked.bam",sample=SAMPLES)

rule markduplicates:
    input:
        l1="/scratch/jc502059/mapping/{sample}_L001_aligned_unsorted.bam",
        l2="/scratch/jc502059/mapping/{sample}_L002_aligned_unsorted.bam"
    output:
        m="mapping/{sample}.duplicates_metrics",
        bam="mapping/{sample}_aligned_unsorted_duplicates_marked.bam"
    shell:
        """
        gatk --java-options "-Dsamjdk.compression_level=5 -Xms4000m -XX:+UseParallelGC -XX:ParallelGCThreads=2" \
         MarkDuplicates \
         --INPUT {input.l1} \
         --INPUT {input.l2} \
         --OUTPUT {output.bam} \
         --METRICS_FILE {output.m} \
         --VALIDATION_STRINGENCY SILENT \
         --OPTICAL_DUPLICATE_PIXEL_DISTANCE 2500 \
         --ASSUME_SORT_ORDER "queryname" \
         --CREATE_INDEX true \
         --MAX_RECORDS_IN_RAM 5000000 \
         --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 800
         """

