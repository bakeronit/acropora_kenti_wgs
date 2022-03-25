#!/usr/bin/bash

IN=[i.strip() for i in open('../00.rawdata/rawfiles/inner_reefs.txt','rt').readlines()]
OUT=[i.strip().split()[1] for i in open('../00.rawdata/rawfiles/outer_reefs.txt','rt').readlines()]

rule all:
    input:
        expand("mapping/{sample}_aligned_duplicates_marked_sorted.bam", sample=IN+OUT) 

rule SortAndFixTags:
    input:
        bam="mapping/{sample}_aligned_unsorted_duplicates_marked.bam",
        reference="/home/jc502059/bioprojects/atenuis_inshore_offshore/00.rawdata/genome/reference.fasta"
    output:
        protected("mapping/{sample}_aligned_duplicates_marked_sorted.bam")
    shell:
        """
        gatk --java-options "-Dsamjdk.compression_level=5 -Xms4000m" \
        SortSam \
        --INPUT {input.bam} \
        --OUTPUT /dev/stdout \
        --SORT_ORDER "coordinate" \
        --CREATE_INDEX false \
        --CREATE_MD5_FILE false \
        | \
        gatk --java-options "-Dsamjdk.compression_level=5 -Xms500m" \
        SetNmMdAndUqTags \
        --INPUT /dev/stdin \
        --OUTPUT {output} \
        --CREATE_INDEX true \
        --REFERENCE_SEQUENCE {input.reference}
        """
