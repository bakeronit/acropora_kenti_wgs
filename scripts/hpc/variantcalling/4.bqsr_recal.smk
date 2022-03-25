#!/usr/bin/env python

SAMPLES=[ i.strip() for i in open("sample.list","r").readlines()]

rule all:
    input:
        #expand("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/tables/{sample}.{n}.recal_data.table", sample=SAMPLES, n=['0000','0001','0002','0003','0004'])
        #expand("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/tables/{sample}.recal_data.table", sample=SAMPLES)
        #expand("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/recal_bam/{sample}.recal.bam", sample=SAMPLES)
        expand("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/post_tables/{sample}.recal_data.table", sample=SAMPLES)
        #expand("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/anacov/{sample}.anacov.pdf", sample=SAMPLES),
        #expand("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/anacov/{sample}.anacov.csv", sample=SAMPLES)

rule BaseRecalibrator:
    input:
        ref="genome/reference.fasta",
        snp="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.hf_pass.snps.vcf.gz",
        indel="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.hf_pass.indels.vcf.gz",
        bam="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/bam_files/{sample}_aligned_duplicates_marked_sorted.bam",
        interval="intervals/{n}-scattered.interval_list"
    output:
        temp("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/tables/{sample}.{n}.recal_data.table")
    shell:
        """
        gatk --java-options "-Xmx7G -DGATK_STACKTRACE_ON_USER_EXCEPTION=true" \
        BaseRecalibrator \
        -R {input.ref} \
        -L {input.interval} \
        -I {input.bam} \
        --known-sites {input.snp} \
        --known-sites {input.indel} \
        -O {output}
        """

rule gatherBQSR:
    input:
        t1="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/tables/{sample}.0000.recal_data.table",
        t2="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/tables/{sample}.0001.recal_data.table",
        t3="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/tables/{sample}.0002.recal_data.table",
        t4="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/tables/{sample}.0003.recal_data.table",
        t5="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/tables/{sample}.0004.recal_data.table"
    output:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/tables/{sample}.recal_data.table"
    shell:
        """
        gatk GatherBQSRReports \
        -I {input.t1} \
        -I {input.t2} \
        -I {input.t3} \
        -I {input.t4} \
        -I {input.t5} \
        -O {output} 
        """

rule applyBQSR:
    input:
        table="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/tables/{sample}.recal_data.table",
        ref="genome/reference.fasta",
        bam="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/bam_files/{sample}_aligned_duplicates_marked_sorted.bam"
    output:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/recal_bam/{sample}.recal.bam"
    shell:
        """
        gatk ApplyBQSR \
        --java-options "-Xmx10G -Dsamjdk.compression_level=5 -DGATK_STACKTRACE_ON_USER_EXCEPTION=true" \
        -R {input.ref} \
        -I {input.bam} \
        --bqsr-recal-file {input.table} \
        -O {output}
        """

rule BaseRecalibrator_post:
    input:
        ref="genome/reference.fasta",
        snp="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.hf_pass.snps.vcf.gz",
        indel="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.hf_pass.indels.vcf.gz",
        bam="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/recal_bam/{sample}.recal.bam",
        interval="intervals/{n}-scattered.interval_list"
    output:
        temp("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/post_tables/{sample}.{n}.recal_data.table")
    shell:
        """
        gatk --java-options "-Xmx7G -DGATK_STACKTRACE_ON_USER_EXCEPTION=true" \
        BaseRecalibrator \
        -R {input.ref} \
        -L {input.interval} \
        -I {input.bam} \
        --known-sites {input.snp} \
        --known-sites {input.indel} \
        -O {output}
        """

rule gatherBQSR_post:
    input:
        t1="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/post_tables/{sample}.0000.recal_data.table",
        t2="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/post_tables/{sample}.0001.recal_data.table",
        t3="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/post_tables/{sample}.0002.recal_data.table",
        t4="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/post_tables/{sample}.0003.recal_data.table",
        t5="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/post_tables/{sample}.0004.recal_data.table"
    output:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/post_tables/{sample}.recal_data.table"
    shell:
        """
        gatk GatherBQSRReports \
        -I {input.t1} \
        -I {input.t2} \
        -I {input.t3} \
        -I {input.t4} \
        -I {input.t5} \
        -O {output} 
        """

rule AnalyseCovariates:
    input:
        before="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/tables/{sample}.recal_data.table",
        after="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/post_tables/{sample}.recal_data.table"
    output:
        pdf="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/anacov/{sample}.anacov.pdf",
        csv="/home/577/jz6367/scratch/atenius_wgs_data/bqsr/anacov/{sample}.anacov.csv"
    shell:
        """
        gatk AnalyzeCovariates \
        --java-options "-DGATK_STACKTRACE_ON_USER_EXCEPTION=true" \
        -before {input.before} \
        -after {input.after} \
        -plots {output.pdf} \
        -csv {output.csv}
        """


