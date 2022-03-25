#!/usr/bin/env python
import glob,os,re

PRE=[re.sub('_R1_001.fastq.gz','',os.path.basename(i)) for i in glob.glob("/home/jc502059/bioprojects/atenuis_inshore_offshore/00.rawdata/rawfiles/BEL3707_20170808/BEL*/*R1_001.fastq.gz")]
REFERENCE="/home/jc502059/bioprojects/atenuis_inshore_offshore/00.rawdata/genome/reference.fasta"

rule all:
    input:
        expand("/scratch/jc502059/mapping/{batch}/{prefix}_aligned_unsorted.bam", batch=['BEL3707_20170808','BEL3707_20170810_GBRF_connectivity'],prefix=PRE)

wildcard_constraints:
    batch="BEL3707_20170808|BEL3707_20170810_GBRF_connectivity",
    prefix="|".join(PRE)

def findfiles(wildcards):
    return {'r1': glob.glob(f'/home/jc502059/bioprojects/atenuis_inshore_offshore/00.rawdata/rawfiles/{wildcards.batch}/BEL*/{wildcards.prefix}_R1_001.fastq.gz')[0],
            'r2': glob.glob(f'/home/jc502059/bioprojects/atenuis_inshore_offshore/00.rawdata/rawfiles/{wildcards.batch}/BEL*/{wildcards.prefix}_R2_001.fastq.gz')[0]}

rule fastq2ubam:
    input:
        unpack(findfiles)
    output:
        temp("ubam/{batch}/{prefix}.ubam")
    threads: 1
    shell:
        """
        flowcell=`zcat {input.r1} | sed -n '1p'| awk -F':' '{{ print $3}}'`  ## for some unknow reason, using head -n1 here will cause error.
        sample=$( echo {wildcards.prefix} |cut -d"_" -f1,2 ) 
        barcode=$( echo {wildcards.prefix} |cut -d"_" -f3 ) 
        batch=$( echo {wildcards.batch} | cut -d "_" -f 2) # add batch info as well.
        lane=$( echo {wildcards.prefix} |cut -d"_" -f4 )
        picard FastqToSam \
         FASTQ={input.r1} \
         FASTQ2={input.r2} \
         OUTPUT={output} \
         READ_GROUP_NAME=$sample.$barcode$batch.$lane \
         SAMPLE_NAME=$sample \
         LIBRARY_NAME=$sample \
         PLATFORM_UNIT=$flowcell.$lane.$barcode$batch \
         PLATFORM=illumina \
        """

rule markadapters:
    input:
        "ubam/{batch}/{prefix}.ubam"
    output:
        m="ubam/{batch}/{prefix}.txt",
        o="ubam/{batch}/{prefix}_markadapters.ubam"
    threads: 1
    shell:
        """
        picard MarkIlluminaAdapters \
         INPUT={input} \
         METRICS={output.m} \
         OUTPUT={output.o}
        """

bwa_version = subprocess.check_output("bwa 2>&1 | grep -e 'Version'", shell=True).decode("utf-8").rstrip()

rule mapping_and_merge_pipe:
    input:
        ubam="ubam/{batch}/{prefix}_markadapters.ubam",
        reference=REFERENCE
    output:
        "/scratch/jc502059/mapping/{batch}/{prefix}_aligned_unsorted.bam"
    params:
        v_bwa = bwa_version
    log:
        "logs/{batch}/{prefix}.bwa.stderr.log"
    threads: 12
    shell:
        """
        java -Dsamjdk.compression_level=5 -Xms3000m -jar $PICARD_HOME/picard.jar SamToFastq \
         INPUT={input.ubam} \
         FASTQ=/dev/stdout \
         INTERLEAVE=true \
         CLIPPING_ATTRIBUTE=XT \
         CLIPPING_ACTION=2 \
         NON_PF=true | \
         bwa mem -M -p -v 3 -t {threads} {input.reference} /dev/stdin - 2> >(tee {log} >&2) | \
        gatk --java-options "-Dsamjdk.compression_level=5 -Xms3000m" \
        MergeBamAlignment \
        --VALIDATION_STRINGENCY SILENT \
        --CREATE_INDEX true \
        --ATTRIBUTES_TO_RETAIN XS \
        --ALIGNED_BAM /dev/stdin  \
        --UNMAPPED_BAM {input.ubam} \
        --OUTPUT {output} \
        --REFERENCE_SEQUENCE {input.reference} \
        --PAIRED_RUN true \
        --SORT_ORDER "unsorted" \
        --IS_BISULFITE_SEQUENCE false \
        --ALIGNED_READS_ONLY false \
        --CLIP_ADAPTERS false \
        --MAX_RECORDS_IN_RAM 2000000 \
        --ADD_MATE_CIGAR true \
        --MAX_INSERTIONS_OR_DELETIONS -1 \
        --INCLUDE_SECONDARY_ALIGNMENTS true \
        --PRIMARY_ALIGNMENT_STRATEGY MostDistant \
        --PROGRAM_RECORD_ID "bwamem" \
        --PROGRAM_GROUP_VERSION "{params.v_bwa}" \
        --PROGRAM_GROUP_COMMAND_LINE "bwa mem -p -v 3 -t 10 {input.reference}" \
        --PROGRAM_GROUP_NAME "bwamem" \
        --UNMAPPED_READ_STRATEGY COPY_TO_TAG \
        --ALIGNER_PROPER_PAIR_FLAGS true \
        --UNMAP_CONTAMINANT_READS true
        """
