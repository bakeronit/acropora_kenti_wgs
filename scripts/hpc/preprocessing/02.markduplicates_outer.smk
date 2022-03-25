#!/usr/bin/env python

SAMPLES=[i.strip().split()[1] for i in open('../00.rawdata/rawfiles/outer_reefs.txt','rt').readlines()]

rule all:
    input:
        expand("mapping/{sample}_aligned_unsorted_duplicates_marked.bam",sample=SAMPLES)

rule markduplicates:
    input:
        b1l1="/scratch/jc502059/mapping/BEL3707_20170808/{sample}_L001_aligned_unsorted.bam",
        b1l2="/scratch/jc502059/mapping/BEL3707_20170808/{sample}_L002_aligned_unsorted.bam",
        b2l1="/scratch/jc502059/mapping/BEL3707_20170810_GBRF_connectivity/{sample}_L001_aligned_unsorted.bam",
        b2l2="/scratch/jc502059/mapping/BEL3707_20170810_GBRF_connectivity/{sample}_L002_aligned_unsorted.bam"
    output:
        m="mapping/{sample}.duplicates_metrics",
        bam="mapping/{sample}_aligned_unsorted_duplicates_marked.bam"
    shell:
        """
        gatk --java-options "-Dsamjdk.compression_level=5 -Xms4000m -XX:+UseParallelGC -XX:ParallelGCThreads=2" \
         MarkDuplicates \
         --INPUT {input.b1l1} \
         --INPUT {input.b1l2} \
         --INPUT {input.b2l1} \
         --INPUT {input.b2l2} \
         --OUTPUT {output.bam} \
         --METRICS_FILE {output.m} \
         --VALIDATION_STRINGENCY SILENT \
         --OPTICAL_DUPLICATE_PIXEL_DISTANCE 2500 \
         --ASSUME_SORT_ORDER "queryname" \
         --CREATE_INDEX true \
         --MAX_RECORDS_IN_RAM 5000000 \
         --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 800
         """
