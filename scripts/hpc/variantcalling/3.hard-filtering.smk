#!/usr/bin/env python

REFERENCE="genome/reference.fa"

rule all:
    input:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.hf_pass.snps.vcf.gz",
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.hf_pass.indels.vcf.gz"

rule gatkSelectSnps:
    input:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.all.v0.vcf.gz"
    output:
        temp("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.all.snps.vcf.gz")
    shell:
        """
        gatk SelectVariants \
        -V {input} \
        -select-type SNP \
        -O {output}
        """

rule gatkSelectindels:
    input:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.all.v0.vcf.gz"
    output:
        temp("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.all.indels.vcf.gz")
    shell:
        """
        gatk SelectVariants \
        -V {input} \
        -select-type INDEL \
        -O {output}
        """

rule hardfiltersnps:
    input:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.all.snps.vcf.gz"
    output:
        temp("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.hardfilter.snps.vcf.gz")
    shell:
        """
        gatk --java-options "-Xmx29g -DGATK_STACKTRACE_ON_USER_EXCEPTION=true" \
        VariantFiltration \
        -V {input} \
        -filter "QD < 10.0" --filter-name "QD10" \
        -filter "QUAL < 30.0" --filter-name "QUAL30" \
        -filter "SOR > 3.0" --filter-name "SOR3" \
        -filter "FS > 60.0" --filter-name "FS60" \
        -filter "MQ < 40.0" --filter-name "MQ40" \
        -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
        -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
        --verbosity ERROR \
        -O {output}
        """

rule hardfilterindels:
    input:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.all.indels.vcf.gz"
    output:
        temp("/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.hardfilter.indels.vcf.gz")
    shell:
        """
        gatk --java-options "-Xmx29g -DGATK_STACKTRACE_ON_USER_EXCEPTION=true" \
        VariantFiltration \
        -V {input} \
        -filter "QD < 2.0" --filter-name "QD2" \
        -filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
        -filter "InbreedingCoeff < -0.8" --filter-name "InbreedingCoeff-0.8" \
        -filter "FS > 200.0" --filter-name "FS200" \
        -filter "QUAL < 20.0" --filter-name "QUAL20" \
        -filter "SOR > 10.0" --filter-name "SOR10" \
        --verbosity ERROR \
        -O {output}
        """

rule hdsnps:
    input:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.hardfilter.snps.vcf.gz"
    output:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.hf_pass.snps.vcf.gz"
    shell:
        """
        gatk --java-options "-Xmx29g -DGATK_STACKTRACE_ON_USER_EXCEPTION=true" \
        SelectVariants \
        -V {input} \
        -O {output} \
        --restrict-alleles-to BIALLELIC \
        --exclude-filtered true
        """

rule hdindels:
    input:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.hardfilter.indels.vcf.gz"
    output:
        "/home/577/jz6367/scratch/atenius_wgs_data/bqsr/atenius.hf_pass.indels.vcf.gz"
    shell:
        """
        gatk --java-options "-Xmx29g -DGATK_STACKTRACE_ON_USER_EXCEPTION=true" \
        SelectVariants \
        -V {input} \
        -O {ouput} \
        --exclude-filtered true
        """
