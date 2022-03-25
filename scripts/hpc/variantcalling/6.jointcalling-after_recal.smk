#!/usr/bin/env python

rule all:
    input:
        "/home/577/jz6367/scratch/atenius_wgs_data/variant_call_after_recal/atenius.gatk.v1.vcf.gz"

rule GenomicsDBImport:
    input:
        smap="sample-map2.txt",
        interval="intervals_500/{n}-scattered.interval_list"
    output:
        db=directory("/home/577/jz6367/scratch/atenius_wgs_data/variant_call_after_recal/genomicsDB/{n}.db"),
        tar="/home/577/jz6367/scratch/atenius_wgs_data/variant_call_after_recal/genomicsDB/{n}.db.tar"
    threads: 6
    shell:
        """
        gatk --java-options "-Xmx4g -Xms4g" \
        GenomicsDBImport \
        --genomicsdb-workspace-path {output.db} \
        --overwrite-existing-genomicsdb-workspace \
        --intervals {input.interval} \
        --sample-name-map {input.smap} \
        --reader-threads 5 \
        --batch-size 50

        tar -cf {output.tar} {output.db}
        """

rule genotypeGVCFs:
    input:
        db="/home/577/jz6367/scratch/atenius_wgs_data/variant_call_after_recal/genomicsDB/{n}.db",
        ref="genome/reference.fasta",
        interval="intervals_500/{n}-scattered.interval_list"
    output:
        "/home/577/jz6367/scratch/atenius_wgs_data/variant_call_after_recal/vcf/{n}.vcf.gz"
    threads: 1
    shell:
        """
        gatk --java-options "-Xmx8g -Xms8g" \
        GenotypeGVCFs \
        -R {input.ref} \
        --heterozygosity 0.01 \
        -V gendb://{input.db} \
        -L {input.interval} \
        --only-output-calls-starting-in-intervals \
        -O {output}
        """

rule GatherVCFs:
    input:
        expand("/home/577/jz6367/scratch/atenius_wgs_data/variant_call_after_recal/vcf/{n}.vcf.gz",n=[f'{i:04}' for i in range(500)])
    output:
        "/home/577/jz6367/scratch/atenius_wgs_data/variant_call_after_recal/atenius.gatk.v1.vcf.gz"
    threads: 1 
    params:
        " -I ".join(f"/home/577/jz6367/scratch/atenius_wgs_data/variant_call_after_recal/vcf/{i:04}.vcf.gz" for i in range(500) )
    shell:
        """
        gatk --java-options "-Xmx6g -Xms6g" \
        GatherVcfs \
        -I {params} \
        --CREATE_INDEX true \
        -O {output} 
        """
