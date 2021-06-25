rule bam_bigwig:
    input:
        bam=rules.bam_sort.output.bam,
        bai=rules.bam_sort.output.bai
    output:
        "results/bigwig/{sample}_{genome}.bw"
    benchmark:
        "logs/benchmarks/bigwig/{sample}_{genome}.bw.txt"
    log:
        "logs/bigwig/{sample}_{genome}.bw.log"
    conda:
        "../envs/deeptools.yaml"

    shell: "bamCoverage -b {input.bam} -o {output} &> {log}"