localrules: bams_multiqc

rule align_reads_se:
    input:
        sample=lambda wildcards: ancient(SAMPLES_DF.loc[wildcards.sample, 'File']),
        indexes=ancient(rules.bowtie2_index.output)
    output:
        temp("results/bams/{sample}_{genome}.bam")
    benchmark:
        "benchmarks/bams/{sample}_{genome}.bam.txt"
    log:
        "logs/bams/{sample}_{genome}.bam.log"
    params:
        index=lambda wildcards, input: input.indexes[0].replace(".1.bt2",""),
        extra=config['bowtie2_index']['extra']
    threads: config['bowtie2_index']['threads']
    # Wrapper uses old 2.4.1 bowtie2, which doesn't work on my mac
    conda: "../envs/bowtie.yaml"
    wrapper:
        "0.74.0/bio/bowtie2/align"

rule bam_sort:
    input: rules.align_reads_se.output
    output:
        bam="results/bams_sorted/{sample}_{genome}.sorted.bam",
        bai="results/bams_sorted/{sample}_{genome}.sorted.bai",
    log:
        "logs/bams_sorted/{sample}_{genome}.sorted.bam.log",
    benchmark:
        "benchmarks/bams_sorted/{sample}_{genome}.sorted.bam.txt",
    params:
        sort_order="coordinate",
        # see all options: https://gatk.broadinstitute.org/hc/en-us/articles/360036510732-SortSam-Picard-
        extra="VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=TRUE"
    wrapper:
        "0.74.0/bio/picard/sortsam"

rule bams_multiqc:
    input:
        expand(
            rules.align_reads_se.log,
            sample=SAMPLES_DF.index,
            allow_missing=True
        )
    output:
        "results/qc/multiqc/bams_{genome}.html",
         directory("results/qc/multiqc/bams_{genome}_data")
    log: "logs/qc/multiqc/bams_{genome}.log"
    wrapper:
        "0.74.0/bio/multiqc"