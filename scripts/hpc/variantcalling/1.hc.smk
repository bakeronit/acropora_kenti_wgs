#!/usr/bin/env python

REFERENCE="genome/reference.fasta"

SAMPLES=[ i.strip() for i in open("sample.list","r").readlines()]

rule all:
    input:
        #expand("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/gvcf/{sample}_{n}.g.vcf", sample=SAMPLES, n=['0000','0001','0002','0003','0004'])
        expand("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/gvcf/{sample}.g.vcf", sample=SAMPLES)

rule hc:
    input:
        reference=REFERENCE,
        interval="intervals/{n}-scattered.interval_list",
        bam="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/bam_files/{sample}_aligned_duplicates_marked_sorted.bam"
    output:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/gvcf/{sample}_{n}.g.vcf"
    threads: 8
    shell:
        """
        gatk --java-options "-Xmx20G -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10" \
        HaplotypeCaller \
        -R {input.reference} \
        -I {input.bam} \
        -L {input.interval} \
        -O {output} \
        --pair-hmm-implementation AVX_LOGLESS_CACHING_OMP \
        --native-pair-hmm-threads {threads} \
        --heterozygosity 0.01 \
        -G StandardAnnotation \
        -G StandardHCAnnotation \
        -G AS_StandardAnnotation \
        -GQB 10 -GQB 20 -GQB 30 -GQB 40 -GQB 50 -GQB 60 -GQB 70 -GQB 80 -GQB 90 \
        -contamination 0 -ERC GVCF 
        """

rule gathergvcf:
    input:
        g1="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/gvcf/{sample}_0000.g.vcf",
        g2="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/gvcf/{sample}_0001.g.vcf",
        g3="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/gvcf/{sample}_0002.g.vcf",
        g4="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/gvcf/{sample}_0003.g.vcf",
        g5="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/gvcf/{sample}_0004.g.vcf"
    output:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/gvcf/{sample}.g.vcf"
    shell:
        """
        gatk --java-options "-Xmx10G" \
        MergeVcfs \
        --INPUT {input.g1} \
        --INPUT {input.g2} \
        --INPUT {input.g3} \
        --INPUT {input.g4} \
        --INPUT {input.g5} \
        --OUTPUT {output}
        """
