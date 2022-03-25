gatk SplitIntervals --java-options "-Xmx3g" -R ../00.rawdata/genome/reference.fasta -scatter-count 5 -O intervals

gatk SplitIntervals --java-options "-Xmx3g" -R genome/reference.fasta -scatter-count 500 -O intervals_500
